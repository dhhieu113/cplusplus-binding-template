cmake_minimum_required(VERSION 3.5)

project(cppbindingtemplate LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
# Enable PIC by default for shared libraries
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ---- STATIC LIBRARY ----
add_library(cppbindingtemplate_static STATIC src/cppbindingtemplate/cppbindingtemplate.cpp)
# Enable Position Independent Code for the static library so it can be used in shared libraries
set_property(TARGET cppbindingtemplate_static PROPERTY POSITION_INDEPENDENT_CODE ON)
target_include_directories(cppbindingtemplate_static
    PRIVATE src
    PUBLIC include)

# ---- SHARED LIBRARY ----
add_library(cppbindingtemplate_shared SHARED src/cppbindingtemplate/cppbindingtemplate.cpp)
target_include_directories(cppbindingtemplate_shared
    PRIVATE src
    PUBLIC include)

# Ensure proper output names (so both are "cppbindingtemplate", not suffixed)
set_target_properties(cppbindingtemplate_static PROPERTIES OUTPUT_NAME "cppbindingtemplate")
set_target_properties(cppbindingtemplate_shared PROPERTIES OUTPUT_NAME "cppbindingtemplate")

# On Windows, differentiate import libs and DLLs
if (WIN32)
    set_target_properties(cppbindingtemplate_shared PROPERTIES
        RUNTIME_OUTPUT_NAME "cppbindingtemplate"
        ARCHIVE_OUTPUT_NAME "cppbindingtemplate"
        LIBRARY_OUTPUT_NAME "cppbindingtemplate")
endif()

# ---- TESTS ----
if (BUILD_TESTING)
    add_executable(test tests/test.cpp)
    target_link_libraries(test PRIVATE cppbindingtemplate_static) # link to static by default
endif()

# ---- .NET BINDING SHIM ----
add_library(cppbindingtemplate_dotnet SHARED cppbindingtemplate_dotnet_shim.cpp)
target_include_directories(cppbindingtemplate_dotnet
    PRIVATE src
    PUBLIC include)

# Link against the static library to ensure all symbols are available
target_link_libraries(cppbindingtemplate_dotnet PRIVATE cppbindingtemplate_static)

# Set output name for the .NET binding
set_target_properties(cppbindingtemplate_dotnet PROPERTIES OUTPUT_NAME "cppbindingtemplate_dotnet")

# On Windows/MinGW, ensure proper naming
if(WIN32 OR MINGW OR MSYS)
    set_target_properties(cppbindingtemplate_dotnet PROPERTIES 
        RUNTIME_OUTPUT_NAME "cppbindingtemplate_dotnet"
        LIBRARY_OUTPUT_NAME "cppbindingtemplate_dotnet"
        ARCHIVE_OUTPUT_NAME "cppbindingtemplate_dotnet")
endif()
