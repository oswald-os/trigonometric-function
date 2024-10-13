# Compiler
CXX = g++

# Compiler flags
CXXFLAGS = -Wall -Wextra -g

# Source files
SRCS = main.cpp FuncA.cpp

# Header files
HEADERS = FuncA.h

# Output executable name
TARGET = bin/FuncA

# Default target
all: $(TARGET)

# Link the program
$(TARGET): $(SRCS) | bin
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRCS)

# Create the bin directory if it doesn't exist
bin:
	mkdir -p bin

# Clean up generated files
clean:
	rm -f $(TARGET)
