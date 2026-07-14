#include <stdio.h>

/* int, 3 return paths */
int f(int x) {
    if (x > 10) {
        return 1;
    }
    if (x < 0) {
        return -1;
    }
    return 0;
}

/* float, 3 return paths */
float g(float y) {
    if (y > 1.0f) {
        return 2.0f;
    }
    if (y < 0.0f) {
        return -1.0f;
    }
    return 0.5f;
}

/* void, 3 return paths */
void h(int n) {
    if (n > 0) {
        printf("positive\n");
        return;
    }
    if (n < 0) {
        printf("negative\n");
        return;
    }
    printf("zero\n");
    return;
}

int main() {
    int r1 = f(15);
    printf("f(15) = %d\n", r1);

    float r2 = g(2.5f);
    printf("g(2.5) = %f\n", r2);

    h(5);
    h(-3);
    h(0);

    return 0;
}
