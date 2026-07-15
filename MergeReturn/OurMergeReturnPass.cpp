#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"

#include <vector>

using namespace llvm;

namespace {

struct MergeReturnPass : public FunctionPass {

    static char ID;

    BasicBlock *ExitBlock = nullptr;

    MergeReturnPass() : FunctionPass(ID) {}

    BasicBlock *getExitBlock() const { return ExitBlock; }

    bool runOnFunction(Function &F) override {

        ExitBlock = nullptr;

        std::vector<ReturnInst *> Returns;

        for (BasicBlock &BB : F)
            if (auto *RI = dyn_cast<ReturnInst>(BB.getTerminator()))
                Returns.push_back(RI);

        if (Returns.size() <= 1) {
            if (!Returns.empty())
                ExitBlock = Returns[0]->getParent();
            return false;
        }

        LLVMContext &Ctx = F.getContext();
        Type        *RetTy = F.getReturnType();

        ExitBlock = BasicBlock::Create(Ctx, "unified_exit", &F);

        PHINode *RetPHI = nullptr;

        IRBuilder<> Builder(ExitBlock);

        if (!RetTy->isVoidTy()) {
            RetPHI = Builder.CreatePHI(RetTy, Returns.size(), "retval");
            Builder.CreateRet(RetPHI);
        } else {
            Builder.CreateRetVoid();
        }

        for (ReturnInst *RI : Returns) {
            BasicBlock *OldBB = RI->getParent();

            if (RetPHI != nullptr)
                RetPHI->addIncoming(RI->getReturnValue(), OldBB);

            IRBuilder<> LocalBuilder(RI);
            LocalBuilder.CreateBr(ExitBlock);
            RI->eraseFromParent();
        }

        return true;
    }

    void print(raw_ostream &OS, const Module *) const override {
        if (ExitBlock)
            OS << "[matf-mergereturn] exit block: " << ExitBlock->getName() << "\n";
        else
            OS << "[matf-mergereturn] no exit block (function not yet processed)\n";
    }
};

} // end anonymous namespace

char MergeReturnPass::ID = 0;

static RegisterPass<MergeReturnPass> X(
    "matf-mergereturn",
    "Unify function exit nodes (matf-mergereturn)",
    /*CFGOnly=*/false,
    /*isAnalysis=*/false);