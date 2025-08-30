# C++ Binding Template

[![CI](https://github.com/yourusername/cppbindingtemplate/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/cppbindingtemplate/actions/workflows/ci.yml)

[![YourName.CppBindingTemplate](https://img.shields.io/nuget/v/YourName.CppBindingTemplate)](https://www.nuget.org/packages/YourName.CppBindingTemplate)

# C++ Binding Template with Hello World

This is a template for creating C++ libraries with .NET bindings. It demonstrates a simple "Hello World" message that includes platform information.

## Prerequisites

- .NET SDK 6.0 or higher
- C++ build tools (for building the native library)

## Building

1. First, build the native library using CMake:

```bash
mkdir build && cd build
cmake ..
cmake --build . --config Release
```

2. Build the .NET binding:

```bash
cd dotnet
dotnet build -c Release
```

## Usage in .NET

```csharp
using CppBindingTemplate;

// Get platform-specific hello world message
string message = HelloWorldProvider.GetHelloWorld();
Console.WriteLine(message);
```

## Features

- Cross-platform (Windows, macOS, Linux)
- Shows platform information in the Hello World message
- Clean separation between native code and .NET binding
- Uses modern CMake and .NET tooling

## Project Structure

- `include/cppbindingtemplate/`: C++ header files
- `src/cppbindingtemplate/`: C++ implementation files
- `dotnet/`: .NET binding code
- `dotnetExample/`: Example .NET application using the binding
- `tests/`: C++ tests

## Example

Check the Example project for a complete demonstration.

## NuGet Package

When the project is built, a NuGet package is generated in the output directory. You can use this package in other .NET projects.
