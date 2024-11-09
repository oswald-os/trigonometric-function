#include "../FuncA.h"

int main()
{
    FuncA funcA;

    // sin(0) = 0
    if (abs(funcA.taylor_sine(0, 5) - 0) < 1e-6)
        return 0;
    else
        return 1;
}