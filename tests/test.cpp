#include "cppbindingtemplate/cppbindingtemplate.h"
#include <iostream>

int main() {
	std::string message = cppbindingtemplate::helloWorld();
	std::cout << message << std::endl;
	return 0;
}
