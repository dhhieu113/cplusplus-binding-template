#include "cppbindingtemplate/cppbindingtemplate.h"
#include <cstring>

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif

extern "C" {
    // This function returns a C-compatible string pointer that can be marshaled to .NET
    EXPORT const char* HelloWorld() {
        std::string message = cppbindingtemplate::helloWorld();
#ifdef _WIN32
        // Allocate memory for the string that will be returned to .NET
        char* result = new char[message.length() + 1];
        strcpy_s(result, message.length() + 1, message.c_str());
        return result;
#else
        // Allocate memory for the string that will be returned to .NET
        char* result = new char[message.length() + 1];
        strcpy(result, message.c_str());
        return result;
#endif
    }

    // This function frees the memory allocated by HelloWorld
    EXPORT void FreeHelloWorldString(const char* ptr) {
        delete[] ptr;
    }
}
