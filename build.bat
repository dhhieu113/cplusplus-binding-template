@echo off
REM Build script for CppBindingTemplate using MinGW64

echo Building C++ binding template...

REM Create output directories
mkdir -p bin\Release
mkdir -p bin\Release\runtimes\win-x64\native

REM Compile static library
echo Compiling static library...
g++ -c -std=c++11 -fPIC -o bin\cppbindingtemplate.o src\cppbindingtemplate\cppbindingtemplate.cpp -I include

REM Create static library
echo Creating static library...
ar rcs bin\Release\libcppbindingtemplate.a bin\cppbindingtemplate.o

REM Compile shared library
echo Compiling shared library...
g++ -shared -std=c++11 -o bin\Release\cppbindingtemplate.dll src\cppbindingtemplate\cppbindingtemplate.cpp -I include

REM Compile .NET binding shim
echo Compiling .NET binding shim...
g++ -shared -std=c++11 -o bin\Release\cppbindingtemplate_dotnet.dll cppbindingtemplate_dotnet_shim.cpp bin\cppbindingtemplate.o -I include

REM Copy the DLL to the runtimes folder (for .NET projects)
echo Copying DLLs to runtime folders...
copy bin\Release\cppbindingtemplate_dotnet.dll bin\Release\runtimes\win-x64\native\

REM Compile and run tests
echo Compiling tests...
g++ -std=c++11 -o bin\test.exe tests\test.cpp -I include -L bin\Release -lcppbindingtemplate

echo.
echo Build completed successfully!
echo.
echo You can now run:
echo - Tests: .\bin\test.exe
echo - .NET example (after building the .NET project): cd dotnetExample ^&^& dotnet run
