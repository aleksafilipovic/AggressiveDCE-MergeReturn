#include <stdio.h>

// Sabira brojeve u petlji, ali ima mrtve promenljive i redundantna grananja
int kalkulator_petlja(int n, int lim) {
    int suma = 0;
    int mrtva_suma = 0; // Ova promenljiva se ažurira, ali se nikad ne vraća niti koristi!

    // Petlja koja testira ispravnost analize živosti
    for (int i = 0; i < n; i++) {
        if (i < lim) {
            suma += i;
            mrtva_suma += i * 2; // Dead store / dead computation
        } else {
            // Prazna else grana
        }
    }

    return suma;

    // Sve ispod je mrtvo i nedostižno
    int x = n + lim;
    mrtva_suma = x * 10;
}

// test za DSE
void obrada_pokazivaca(int *ptr, int a) {
    // Prva dva upisa su mrtva
    *ptr = a + 1; 
    *ptr = a + 2; 
    *ptr = a + 3; // jedini živ

    // mrtve lokalne promenljive i aritmetika
    int nebitno = a * 5;
    int jos_nebitnije = nebitno - 2;
}

int main() {
    int rez1 = kalkulator_petlja(10, 5);
    
    int temp = 0;
    obrada_pokazivaca(&temp, rez1);

    // Mrtav kod u mainu
    int provera = temp * 2; // 'provera' se računa ali se nigde ne koristi

    printf("Rezultat prve funkcije: %d\n", rez1);
    printf("Vrednost temp nakon obrade: %d\n", temp);

    return 0;
}