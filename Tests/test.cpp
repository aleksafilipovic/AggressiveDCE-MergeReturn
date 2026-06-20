// test.cpp — test cases for the mergereturn LLVM pass
//
// Contains several functions that each have more than one return
// instruction so the pass always has something to merge.

#include <cstdio>

// ── Test 1: simple int function with two returns ──────────────────────────
int max(int a, int b) {
    if (a > b)
        return a;
    return b;
}

// ── Test 2: three-way branch, three returns ───────────────────────────────
int sign(int x) {
    if (x > 0)  return  1;
    if (x < 0)  return -1;
    return 0;
}

// ── Test 3: void function with early return ───────────────────────────────
void print_if_positive(int x) {
    if (x <= 0)
        return;
    printf("%d\n", x);
    return;
}

// ── Test 4: nested if — four possible return paths ───────────────────────
int classify(int x) {
    if (x < 0) {
        if (x < -100) return -2;
        return -1;
    } else {
        if (x > 100) return  2;
        return  1;
    }
}

// ── Test 5: loop with early-exit return ───────────────────────────────────
int find_first(int *arr, int len, int val) {
    for (int i = 0; i < len; i++) {
        if (arr[i] == val)
            return i;
    }
    return -1;
}

int main() {
    printf("max(3,7)   = %d\n", max(3, 7));
    printf("sign(-5)   = %d\n", sign(-5));
    printf("sign(0)    = %d\n", sign(0));
    printf("classify(200) = %d\n", classify(200));
    print_if_positive(42);
    print_if_positive(-1);

    int arr[] = {10, 20, 30, 40, 50};
    printf("find 30 at index %d\n", find_first(arr, 5, 30));
    printf("find 99 at index %d\n", find_first(arr, 5, 99));
    return 0;
}
