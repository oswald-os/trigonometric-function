#include "../FuncA.h"

int main()
{
    FuncA funcA;

    // sin(pi) ≈ 0
    if(abs(funcA.taylor_sine(3.14159, 10)) < 1e-2)
        return 0;
    else
        return 1;
}