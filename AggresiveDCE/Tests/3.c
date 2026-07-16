#include <stdio.h>

int globalna_promenljiva;

void f() {
    globalna_promenljiva = 5; // ostaje
}

void g() {
    int lokalna = 10; // mrtav store, pregazen u sledecoj
    lokalna = 20;  // mrtav zbog lokalnosti
}

int main() {
    f();
    g();
    printf("Globalna: %d\n", globalna_promenljiva);
    return 0;
}