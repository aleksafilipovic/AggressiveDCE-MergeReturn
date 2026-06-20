git a#!/usr/bin/env bash
# run.sh — compile the pass and run it against the test file
#
# Usage:
#   ./run.sh          # full build + run
#   ./run.sh -k       # keep generated .ll files after the run
#
# Requirements:
#   clang++, opt, llvm-config  — all on PATH and from the same LLVM build.

set -euo pipefail

KEEP_LL=0
[[ "${1:-}" == "-k" ]] && KEEP_LL=1

PASS_SRC="MergeReturnPass/MergeReturnPass.cpp"
PASS_LIB="MergeReturnPass.so"
TEST_SRC="Tests/test.cpp"
BEFORE_LL="before.ll"
AFTER_LL="after.ll"

# ── 1. Compile the pass ──────────────────────────────────────────────────────
echo "==> Compiling pass..."
clang++ -fPIC -g -O2 -fno-rtti -shared \
    $(llvm-config --cppflags --ldflags --libs) \
    -o "$PASS_LIB" "$PASS_SRC"
echo "    -> $PASS_LIB"

# ── 2. Emit LLVM IR for the test program ─────────────────────────────────────
echo "==> Emitting IR ($BEFORE_LL)..."
clang++ -S -fno-discard-value-names -emit-llvm -O0 \
        -Xclang -disable-O0-optnone \
        "$TEST_SRC" -o "$BEFORE_LL"

# ── 3. Run the pass ───────────────────────────────────────────────────────────
echo "==> Running mergereturn pass..."
opt -S -enable-new-pm=0 \
    -load "./$PASS_LIB" \
    -mergereturn \
    "$BEFORE_LL" -o "$AFTER_LL"
echo "    -> $AFTER_LL"

# ── 4. Count ret instructions before / after ──────────────────────────────────
BEFORE_RETS=$(grep -c '^\s*ret ' "$BEFORE_LL" || true)
AFTER_RETS=$(grep  -c '^\s*ret ' "$AFTER_LL"  || true)
echo "==> ret instructions before: $BEFORE_RETS"
echo "==> ret instructions after : $AFTER_RETS"

# ── 5. Compile the optimised IR and run it ────────────────────────────────────
echo "==> Compiling and running optimised binary..."
clang++ "$AFTER_LL" -o test_optimised
./test_optimised

# ── 6. Clean up (unless -k flag was given) ────────────────────────────────────
if [[ "$KEEP_LL" -eq 0 ]]; then
    rm -f "$BEFORE_LL" "$AFTER_LL" test_optimised "$PASS_LIB"
    echo "==> Cleaned up temporary files."
fi

echo "==> Done."
