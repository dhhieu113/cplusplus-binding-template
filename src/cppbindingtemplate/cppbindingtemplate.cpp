#include "cppbindingtemplate/cppbindingtemplate.h"
#include <string>

namespace cppbindingtemplate {
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) && !defined(__CYGWIN__)
    std::string helloWorld() {
        return "Hello World - Windows Platform";
    }
#elif defined(__APPLE__)
    std::string helloWorld() {
        return "Hello World - MacOS Platform";
    }
#elif defined(__linux__)
    std::string helloWorld() {
        return "Hello World - Linux Platform";
    }
#else
    std::string helloWorld() {
        return "Hello World - Unknown Platform";
    }
#endif
}
