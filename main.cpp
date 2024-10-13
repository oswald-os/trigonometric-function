#include "./FuncA.h"

int main(int argc, char const *argv[]) {

    // Check if exactly 1 parameters were provided
    // (argc should be 2: program name + 1 parameters)
    if (argc != 2)
    {
        cerr << "Invalid usage: 1 parameter are required" << endl;
        return 0;
    }

    double x;

    try
    {
        x = stod(argv[1]);
    }
    catch (const invalid_argument& e)
    {
        cerr << "Invalid argument: " << e.what() << endl;
        exit(1);
    }
    catch (const out_of_range& e)
    {
        cerr << "Out of range: " << e.what() << endl;
        exit(1);
    }

    FuncA funcA;

    double result = funcA.taylor_sine(x);
    cout << "sin(" << x << ") ≈ " << result << endl;

    return 0;
}
