#ifndef FUNCA_H
#define FUNCA_H

#include <iostream>
#include <cmath>
#include <limits>
using namespace std;


class FuncA {
public:
    double taylor_sine(double x);

private:
    unsigned long long factorial(int n);
};


#endif