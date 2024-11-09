#include "../FuncA.h"

int main()
{
    FuncA funcA;

    // sin(3pi/2) ≈ -1
    if(abs(funcA.taylor_sine(3.14159 * 3 / 2, 10) + 1) < 1e-2)
        return 0;
    else
        return 1;
}