#include "llvm/IR/Function.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Operator.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <vector>
#include <set>
#include <unordered_map>

using namespace llvm;


namespace {
  struct MyPass : public FunctionPass {
    std::unordered_map<Value *, bool> Variables;
    std::unordered_map<Value *, Value *> VariablesMap;
    std::set<Instruction *> InstructionsToRemove; 
    bool InstructionEliminated;
    static char ID; 
    MyPass() : FunctionPass(ID) {}

    void handleOperand(Value *Operand) {
            if (Variables.find(Operand) != Variables.end())
                Variables[Operand] = true;
            if (VariablesMap.find(Operand) != VariablesMap.end())
                Variables[VariablesMap[Operand]] = true;
    }
    //------
    void EliminateDeadInstructions(Function &F, DominatorTree &DT) {

            InstructionsToRemove.clear(); 
            std::unordered_map<Value *, StoreInst *> LastStore; 
            VariablesMap.clear();

            for (BasicBlock &BB: F) {
                for (Instruction &I: BB) {
                    if (auto *store = dyn_cast<StoreInst>(&I)) { 
                        Value *ptr = store->getOperand(1); 

                        if (LastStore.find(ptr) != LastStore.end()) { 
                            StoreInst *OldStore = LastStore[ptr]; 

                            bool safeToRemove =
                                (OldStore->getParent() == store->getParent()) ||
                                DT.dominates(store, OldStore); //getParent na instrukciji vraća BasicBlock kojem ta instrukcija pripada. Proverava se da li su u istom bloku, da ne može da se preskoči jedan store preko druge putanje izvršavanja.
                                                               // Da li store dominira nad OldStore? Ako da, onda je bezbedno obrisati stari bez obzira na grananje.
                            if (safeToRemove) {
                                errs() << "[dse: " << F.getName()
                                       << "]: Dead store detected and removed -> "
                                       << *OldStore << "\n";
                                InstructionsToRemove.insert(OldStore); 
                            }
                        }

                        LastStore[ptr] = store; 
                    }
                    else if (auto *load = dyn_cast<LoadInst>(&I)) {
                        Value* ptr = load->getOperand(0);
                        LastStore.erase(ptr);
                    }
                }
            }

            for (auto& entry: LastStore) { 
                InstructionsToRemove.insert(entry.second);
            }

            
            for (BasicBlock& BB : F) {
                  for (Instruction& I : BB) {
                      if (!I.getType()->isVoidTy() && !isa<CallInst>(&I) && !isa<AllocaInst>(&I) && 
            !isa<PHINode>(&I)) {
                          Variables[&I] = false;
                      }
                      if (isa<LoadInst>(&I)) {
                          VariablesMap[&I] = I.getOperand(0);
                      }
                  }
              }

            for (BasicBlock& BB : F) {
                for (Instruction& I : BB) {
                    if (isa<StoreInst>(&I)) {
                        handleOperand(I.getOperand(0));
                        handleOperand(I.getOperand(1));
                    } else {
                        for (unsigned i = 0; i < I.getNumOperands(); i++) {
                            handleOperand(I.getOperand(i));
                        }
                    }
                }
            }

            for (BasicBlock& BB: F) {
                for (Instruction& I: BB) {
                    if (isa<AllocaInst>(&I) || isa<PHINode>(&I)) {
                        continue;
                    }
                    if (isa<StoreInst>(&I)){
                        Value* ptr = I.getOperand(1);
                        if(Variables.find(ptr) != Variables.end() && !Variables[ptr])
                        InstructionsToRemove.insert(&I);
                    } else {
                        if (Variables.find(&I) != Variables.end() && !Variables[&I]) {
                            InstructionsToRemove.insert(&I);
                        }
                    }
                }
            }

            if (!InstructionsToRemove.empty()) {
                InstructionEliminated = true;
            }

            for (Instruction* I: InstructionsToRemove) {
                errs() << "[dce: " << F.getName() << "]: Instruction " << *I << " deleted\n";
                I->eraseFromParent();
            }
        }
    //------
    void EliminateUnreachableInstructions(Function &F, DominatorTree &DT) {
            std::vector<BasicBlock *> UnreachableBlocks;

            for (BasicBlock &BB : F) {
                if (!DT.isReachableFromEntry(&BB)) {
                    UnreachableBlocks.push_back(&BB);
                }
            }

            if (!UnreachableBlocks.empty()) {
                InstructionEliminated = true;
            }

            for (BasicBlock *BB : UnreachableBlocks) {
                errs() << "[dce]: block " << BB->getName() << " eliminated (unreachable)\n";
                DeleteDeadBlock(BB);
            }
        }    
    //------
    void EliminateEmptyBlocks(Function &F) {
            std::vector<BasicBlock *> EmptyBlocks;

            for (BasicBlock &BB : F) {
                if (&BB == &F.getEntryBlock())
                    continue;

                if (BB.size() == 1) { 
                    Instruction *Term = BB.getTerminator();
                    if (auto *Br = dyn_cast<BranchInst>(Term)) {
                        if (Br->isUnconditional()) { 
                            BasicBlock *Succ = Br->getSuccessor(0); 
                            BB.replaceAllUsesWith(Succ); 
                            EmptyBlocks.push_back(&BB);
                            errs() << "[dce]: block " << BB.getName()
                                   << " eliminated, redirected to: "
                                   << Succ->getName() << "\n";
                        }
                    }
                }
            }

            if (!EmptyBlocks.empty()) {
                InstructionEliminated = true;
                for (BasicBlock *EmptyBlock : EmptyBlocks) {
                    EmptyBlock->eraseFromParent();
                }
            }
        }    
    //------
    void SimplifyRedundantBranches(Function &F) {
            for (BasicBlock &BB: F) {
                Instruction *Term = BB.getTerminator();
                if (auto *Br = dyn_cast<BranchInst>(Term)) {
                    if (Br->isConditional()) {
                        BasicBlock *TrueDest = Br->getSuccessor(0);
                        BasicBlock *FalseDest = Br->getSuccessor(1);

                        if (TrueDest == FalseDest) { 
                            IRBuilder<> Builder(Br);
                            Builder.CreateBr(TrueDest); 
                            Br->eraseFromParent();

                            errs() << "[dce]: redundant branch eliminated\n";
                            InstructionEliminated = true;
                            break;
                        }
                    }
                }
            }
        }    
    //------    
    bool runOnFunction(Function &F) override {
     Variables.clear();
     VariablesMap.clear();
     InstructionsToRemove.clear();

     DominatorTree DT; 
     bool everChanged = false; 

            do {
                InstructionEliminated = false; 

                DT.recalculate(F); // Ako se CFG menjao u prethodnoj rundi, onda se promenilo i stablo. Mora se izgraditi ponovo sa novim cfg-om 
                EliminateDeadInstructions(F, DT);
                EliminateUnreachableInstructions(F, DT);
                EliminateEmptyBlocks(F);
                SimplifyRedundantBranches(F);
                if(InstructionEliminated)
                  everChanged = true;
            } while (InstructionEliminated);

            return everChanged;
        }
  };
}

char MyPass::ID = 0;
static RegisterPass<MyPass> X("my-pass", "MY PASS PROBA",false,false);