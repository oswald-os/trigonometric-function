#include "../FuncA.h"

int main()
{
    FuncA funcA;

    // sin(pi/2) ≈ 1
    if(abs(funcA.taylor_sine(3.14159 / 2, 10) - 1) < 1e-2)
        return 0;
    else
        return 1;
}