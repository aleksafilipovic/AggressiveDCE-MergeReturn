# MergeReturn Pass

## `mergereturn`: Unify function exit nodes

**Faculty of Mathematics, University of Belgrade**  
Course: Compiler Construction (*Konstrukcija kompilatora*)

---

### What it does

The **mergereturn** pass is a function-level transform pass that ensures every
function has **at most one `ret` instruction**.

It works by:

1. Scanning the function for all `ReturnInst` instructions.
2. If there is already ≤ 1 return, the function is left unchanged.
3. Otherwise a new **unified exit block** (`unified_exit`) is appended to the function.
4. For **non-void** functions a `phi` node is placed at the top of the exit
   block; it receives the return value from every original return site.
5. The exit block ends with a single `ret` (or `ret void`).
6. Every original `ret` is replaced by an unconditional branch (`br`) to the
   unified exit block.

The pass tracks the new exit block and exposes it via `getExitBlock()` so
downstream passes can query the unique CFG exit node.

---

### Before / After example

Given:

```c
int sign(int x) {
    if (x > 0)  return  1;
    if (x < 0)  return -1;
    return 0;
}
```

LLVM IR **before** the pass:

```llvm
define i32 @sign(i32 %x) {
entry:
  %cmp1 = icmp sgt i32 %x, 0
  br i1 %cmp1, label %ret_pos, label %check_neg

ret_pos:
  ret i32 1

check_neg:
  %cmp2 = icmp slt i32 %x, 0
  br i1 %cmp2, label %ret_neg, label %ret_zero

ret_neg:
  ret i32 -1

ret_zero:
  ret i32 0
}
```

IR **after** the pass:

```llvm
define i32 @sign(i32 %x) {
entry:
  %cmp1 = icmp sgt i32 %x, 0
  br i1 %cmp1, label %ret_pos, label %check_neg

ret_pos:
  br label %unified_exit

check_neg:
  %cmp2 = icmp slt i32 %x, 0
  br i1 %cmp2, label %ret_neg, label %ret_zero

ret_neg:
  br label %unified_exit

ret_zero:
  br label %unified_exit

unified_exit:
  %retval = phi i32 [ 1, %ret_pos ], [ -1, %ret_neg ], [ 0, %ret_zero ]
  ret i32 %retval
}
```

---

### Build

**Quick (one-liner):**
```bash
./run.sh          # build, run pass, compare ret counts, run binary
./run.sh -k       # same but keeps .ll files for inspection
```

**Manual:**
```bash
# see commands.txt for the full step-by-step sequence
```

**CMake:**
```bash
mkdir build && cd build
cmake .. -DLLVM_DIR=$(llvm-config --cmakedir)
make
```

---

### LLVM version

Tested with **LLVM 14 and LLVM 16**, legacy pass manager (`-enable-new-pm=0`).

---

### References

- [LLVM Passes Documentation — mergereturn](https://llvm.org/docs/Passes.html#id76)
- [Writing an LLVM Pass (legacy PM)](https://llvm.org/docs/WritingAnLLVMPass.html)
