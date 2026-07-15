#include <stdio.h>

int test(int a, int b) {
    // DSE
    int x = a + 5; // mrtav kod 
    x = b * 2;     // Ovaj store je živ jer se x koristi u povratnoj vrednosti

    // DCE (nigde se ne koriste)
    int y = a - b;
    int z = y * 10; 

    // Redundantno Grananje
    // Bez obzira na uslov, obe grane vode u isti blok.
    if (a > b) {
        // Prazna true grana
    } else {
        // Prazna false grana
    }

    return x;

    // Nedostižan kod
    int unreachable_var = a + b;
    printf("Ovo se nikada nece ispisati: %d\n", unreachable_var);
}

int main() {
    int res = test(10, 20);
    printf("Rezultat: %d\n", res);
    return 0;
}