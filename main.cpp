#include "./FuncA.h"

int main(int argc, char const *argv[]) {

    // Check if exactly 2 parameters were provided
    // (argc should be 3: program name + 2 parameters)
    if (argc != 3)
    {
        cerr << "Invalid usage: 2 parameter are required" << endl;
        return 0;
    }

    double x;
    int terms;

    try
    {
        x = stod(argv[1]);
        terms = stoi(argv[2]);
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

    double result = funcA.taylor_sine(x, terms);
    cout << "sin(" << x << ") ≈ " << result << endl;

    return 0;
}
