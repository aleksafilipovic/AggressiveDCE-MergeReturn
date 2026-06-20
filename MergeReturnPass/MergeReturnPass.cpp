/*
 * MergeReturn Pass — Unify function exit nodes
 *
 * Ensures that every function has at most one `ret` instruction.
 * All existing return instructions are replaced by unconditional
 * branches to a single, newly-created "unified exit" basic block
 * that holds the sole ret.  For non-void functions a PHI node in
 * the exit block collects the return values from every original
 * return site.
 *
 * The pass tracks the new exit block so callers can query it via
 * getExitBlock().
 *
 * Faculty of Mathematics, University of Belgrade
 * Course: Compiler Construction (Konstrukcija kompilatora)
 */

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

// ─── logging helpers ─────────────────────────────────────────────────────────

#define LOG_LEVEL 2   // 0 = silent, 1 = errors, 2 = info, 3 = verbose

#define LOG(msg, level)           \
    do {                          \
        if ((level) <= LOG_LEVEL) \
            outs() << msg << "\n";\
    } while (0)

// ─── pass ────────────────────────────────────────────────────────────────────

namespace {

struct MergeReturnPass : public FunctionPass {

    static char ID;

    // The unified exit block created (or kept) by the last run.
    BasicBlock *ExitBlock = nullptr;

    MergeReturnPass() : FunctionPass(ID) {}

    // Public accessor so other passes can query the exit node.
    BasicBlock *getExitBlock() const { return ExitBlock; }

    bool runOnFunction(Function &F) override {

        ExitBlock = nullptr;   // reset for each function

        // ── 1. Collect all return instructions ───────────────────────────

        std::vector<ReturnInst *> Returns;

        for (BasicBlock &BB : F)
            if (auto *RI = dyn_cast<ReturnInst>(BB.getTerminator()))
                Returns.push_back(RI);

        LOG("[mergereturn] function '" << F.getName()
            << "': found " << Returns.size() << " ret(s)", 2);

        // Nothing to do when there is already at most one return.
        if (Returns.size() <= 1) {
            if (!Returns.empty())
                ExitBlock = Returns[0]->getParent();
            LOG("[mergereturn]   -> already unified, skipping", 3);
            return false;
        }

        // ── 2. Create the unified exit block ─────────────────────────────

        LLVMContext &Ctx = F.getContext();
        Type        *RetTy = F.getReturnType();

        // Insert exit block at the very end of the function so it appears
        // last in the IR dump (consistent with how LLVM's own pass works).
        ExitBlock = BasicBlock::Create(Ctx, "unified_exit", &F);

        LOG("[mergereturn]   created exit block: " << ExitBlock->getName(), 3);

        // ── 3. Build the PHI node (non-void functions only) ───────────────

        PHINode *RetPHI = nullptr;

        IRBuilder<> Builder(ExitBlock);

        if (!RetTy->isVoidTy()) {
            RetPHI = Builder.CreatePHI(RetTy, Returns.size(), "retval");
            Builder.CreateRet(RetPHI);
            LOG("[mergereturn]   created PHI node for return value", 3);
        } else {
            Builder.CreateRetVoid();
        }

        // ── 4. Redirect every original ret to the exit block ─────────────

        for (ReturnInst *RI : Returns) {
            BasicBlock *OldBB = RI->getParent();

            // Register this block's return value with the PHI node.
            if (RetPHI != nullptr)
                RetPHI->addIncoming(RI->getReturnValue(), OldBB);

            // Replace the ret with an unconditional branch.
            IRBuilder<> LocalBuilder(RI);
            LocalBuilder.CreateBr(ExitBlock);
            RI->eraseFromParent();

            LOG("[mergereturn]   redirected block '"
                << OldBB->getName() << "' -> unified_exit", 3);
        }

        return true;   // IR was modified
    }

    // Pretty-print analysis result (invoked by opt -analyze).
    void print(raw_ostream &OS, const Module *) const override {
        if (ExitBlock)
            OS << "[mergereturn] exit block: " << ExitBlock->getName() << "\n";
        else
            OS << "[mergereturn] no exit block (function not yet processed)\n";
    }
};

} // end anonymous namespace

// ─── pass registration ───────────────────────────────────────────────────────

char MergeReturnPass::ID = 0;

static RegisterPass<MergeReturnPass> X(
    "mergereturn",
    "Unify function exit nodes (mergereturn)",
    /*CFGOnly=*/false,
    /*isAnalysis=*/false);
