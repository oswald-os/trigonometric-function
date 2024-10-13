#include "./FuncA.h"


double FuncA::taylor_sine(double x) {
    double sine_value = 0.0;
    int terms = 3;

    for (int n = 0; n < terms; ++n) {
        // Taylor series term: ((-1)^n * x^(2n+1)) / (2n+1)!
        double term = pow(-1, n) * pow(x, 2 * n + 1) / factorial(2 * n + 1);
        sine_value += term;

        // Stop early if the term is very small (for better precision)
        if (abs(term) < numeric_limits<double>::epsilon()) {
            break;
        }
    }

    return sine_value;
}

unsigned long long FuncA::factorial(int n) {
    unsigned long long result = 1;

    for (int i = 1; i <= n; ++i) {
        result *= i;
    }

    return result;
}
