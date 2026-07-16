# AggressiveDCE + MergeReturn

LLVM transform pass-evi za optimizaciju IR koda.

**MergeReturn** — spaja više `ret` instrukcija u funkciji u jednu, kreirajući unified exit blok sa PHI čvorom koji skuplja sve return vrednosti.

**AggressiveDCE** — uklanja mrtav kod agresivnije nego standardni DCE, proširen sa Dead Store eliminacijom.

## Setup

1. Preuzmi `make_llvm.sh` sa kursa i izvrši ga
2. Prebaci `MergeReturn/` i `AggresiveDCE/` foldera u `llvm-project/llvm/lib/Transforms/`
3. U `llvm-project/llvm/lib/Transforms/CMakeLists.txt` dodaj:
   ```cmake
   add_subdirectory(MergeReturn)
   add_subdirectory(AggresiveDCE)
   ```
4. U `llvm-project/build` direktorijumu izvrši:
   ```bash
   cmake ..
   make OurMergeReturnPass -j$(nproc)
   make LLVMMyPass -j$(nproc)
   ```

## Pokretanje

Iz repo root foldera:
```bash
./run.sh
```

Ili ručno iz `llvm-project/build`:
```bash
./bin/opt -S -enable-new-pm=0 -load ./lib/OurMergeReturnPass.so -matf-mergereturn MergeReturn/Tests/simple.ll
./bin/opt -S -enable-new-pm=0 -load ./lib/LLVMMyPass.so -my-pass AggresiveDCE/Tests/1.ll
```

---

**Aleksa Filipović** 139/2022  
**Pavle Milićković** 251/2020
