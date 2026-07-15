#!/bin/bash
# prezent.sh — Full MergeReturn Pass Demonstration & Build
# 
# Run from: llvm-project/llvm/lib/Transforms/MergeReturn/
# 
# This script:
#  1. Rebuilds the pass (cmake + make)
#  2. Tests on simple.ll (hand-written IR)
#  3. Tests on example1.c (C source code)

set -e

# Get absolute path to MergeReturn folder BEFORE navigating
MERGE_RETURN_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$MERGE_RETURN_DIR/Tests"

# Navigate to build folder (from MergeReturn, go up 3 levels to llvm-project, then into build)
cd "$MERGE_RETURN_DIR/../../../../build" || exit 1

echo ""
echo "======================================================================"
echo "                  MergeReturn Pass Demonstration"
echo "======================================================================"
echo ""

# ── Step 1: Configure CMake ──────────────────────────────────────────────
echo "[1/6] Configuring CMake..."
echo "Command: cmake ."
cmake . > /dev/null 2>&1
echo "      ✓ CMake configured"

# ── Step 2: Build the pass ───────────────────────────────────────────────
echo "[2/6] Building OurMergeReturnPass..."
echo "Command: make OurMergeReturnPass -j$(nproc)"
make OurMergeReturnPass -j$(nproc) > /dev/null 2>&1
echo "      ✓ Pass built successfully"
echo ""

# ── Test 1: simple.ll (hand-written IR) ─────────────────────────────────
echo "======================================================================"
echo "TEST 1: simple.ll (Hand-written LLVM IR)"
echo "======================================================================"
echo ""

echo "[3/6] Analyzing simple.ll before pass..."
echo "Command: grep -c '^\s*ret ' $TEST_DIR/simple.ll"
BEFORE_SIMPLE=$(grep -c '^\s*ret ' "$TEST_DIR/simple.ll")
echo "      Found: $BEFORE_SIMPLE ret instructions"

echo ""
echo "[4/6] Running matf-mergereturn pass on simple.ll..."
echo "Command: ./bin/opt -S -enable-new-pm=0 \\"
echo "    -load ./lib/OurMergeReturnPass.so \\"
echo "    -matf-mergereturn \\"
echo "    $TEST_DIR/simple.ll -o simple_after.ll"
./bin/opt -S -enable-new-pm=0 \
    -load ./lib/OurMergeReturnPass.so \
    -matf-mergereturn \
    "$TEST_DIR/simple.ll" -o simple_after.ll > /dev/null 2>&1
echo "      ✓ Pass executed"

echo ""
echo "Command: grep -c '^\s*ret ' simple_after.ll"
AFTER_SIMPLE=$(grep -c '^\s*ret ' simple_after.ll)
echo "      Result: $AFTER_SIMPLE ret instructions"
echo ""
echo "      SUMMARY: $BEFORE_SIMPLE → $AFTER_SIMPLE ret(s)"
if [ "$AFTER_SIMPLE" -lt "$BEFORE_SIMPLE" ]; then
    echo "      ✓ Optimization successful!"
else
    echo "      ✗ Warning: ret count did not decrease"
fi

# ── Test 2: example1.c (C source) ────────────────────────────────────────
echo ""
echo "======================================================================"
echo "TEST 2: example1.c (C Source Code)"
echo "======================================================================"
echo ""

echo "[5/6] Compiling example1.c to IR..."
echo "Command: ./bin/clang -S -emit-llvm -O0 $TEST_DIR/example1.c -o example1_before.ll"
./bin/clang -S -emit-llvm -O0 "$TEST_DIR/example1.c" -o example1_before.ll
BEFORE_EXAMPLE=$(grep -c '^\s*ret ' example1_before.ll)
echo "      Generated IR with: $BEFORE_EXAMPLE ret instructions"

echo ""
echo "[6/6] Running matf-mergereturn pass on example1.c..."
echo "Command: ./bin/opt -S -enable-new-pm=0 \\"
echo "    -load ./lib/OurMergeReturnPass.so \\"
echo "    -matf-mergereturn \\"
echo "    example1_before.ll -o example1_after.ll"
./bin/opt -S -enable-new-pm=0 \
    -load ./lib/OurMergeReturnPass.so \
    -matf-mergereturn \
    example1_before.ll -o example1_after.ll > /dev/null 2>&1
echo "      ✓ Pass executed"

echo ""
echo "Command: grep -c '^\s*ret ' example1_after.ll"
AFTER_EXAMPLE=$(grep -c '^\s*ret ' example1_after.ll)
echo "      Result: $AFTER_EXAMPLE ret instructions"
echo ""
echo "      SUMMARY: $BEFORE_EXAMPLE → $AFTER_EXAMPLE ret(s)"
if [ "$AFTER_EXAMPLE" -lt "$BEFORE_EXAMPLE" ]; then
    echo "      ✓ Optimization successful!"
else
    echo "      ✗ Warning: ret count did not decrease"
fi

# ── Final Summary ────────────────────────────────────────────────────────
echo ""
echo "======================================================================"
echo "                         RESULTS SUMMARY"
echo "======================================================================"
echo ""
echo "Test 1 (simple.ll):    $BEFORE_SIMPLE → $AFTER_SIMPLE"
echo "Test 2 (example1.c):   $BEFORE_EXAMPLE → $AFTER_EXAMPLE"
echo ""
echo "Generated files in: $(pwd)"
echo "  - simple_after.ll"
echo "  - example1_before.ll"
echo "  - example1_after.ll"
echo ""
echo "======================================================================"
echo "✓ Demonstration complete!"
echo "======================================================================"
echo ""
