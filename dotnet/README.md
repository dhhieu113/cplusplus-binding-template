# C++ Binding Template .NET Binding

This is a .NET binding for the C++ Binding Template library. It demonstrates a simple "Hello World" message with platform information.

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

## Usage

```csharp
using CppBindingTemplate;

// Get platform-specific hello world message
string message = HelloWorldProvider.GetHelloWorld();
Console.WriteLine(message);
```

## Example

Check the Example project for a complete demonstration.

## NuGet Package

When the project is built, a NuGet package is generated in the output directory. You can use this package in other .NET projects.
