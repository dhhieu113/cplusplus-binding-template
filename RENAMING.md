# CppBindingTemplate Renaming Guide

This project is designed as a template for creating C++ libraries with .NET bindings. When you use this template for your own project, you'll need to rename various elements to match your project name. Follow these steps to rename everything from "CppBindingTemplate" to your own library name.

## Step 1: Choose Your Library Name

First, decide on a name for your library. For this guide, we'll use `YourLibraryName` as an example.

## Step 2: Update File Names and Directories

Rename the following files and directories:

1. Rename directories:
   ```
   include/cppbindingtemplate → include/yourlibraryname
   src/cppbindingtemplate → src/yourlibraryname
   ```

2. Rename files:
   ```
   include/yourlibraryname/cppbindingtemplate.h → include/yourlibraryname/yourlibraryname.h
   src/yourlibraryname/cppbindingtemplate.cpp → src/yourlibraryname/yourlibraryname.cpp
   cppbindingtemplate_dotnet_shim.cpp → yourlibraryname_dotnet_shim.cpp
   dotnet/CppBindingTemplate.csproj → dotnet/YourLibraryName.csproj
   dotnet/CppBindingTemplate.sln → dotnet/YourLibraryName.sln
   dotnet/HelloWorldProvider.cs → dotnet/YourClassNameProvider.cs
   ```

## Step 3: Update Code Content

Search and replace the following strings in all files:

1. In C++ files:
   * Replace `cppbindingtemplate` with `yourlibraryname` (lowercase)
   * Replace `CppBindingTemplate` with `YourLibraryName` (PascalCase)
   * Replace `#include "cppbindingtemplate/cppbindingtemplate.h"` with `#include "yourlibraryname/yourlibraryname.h"`

2. In CMakeLists.txt:
   * Replace `project(cppbindingtemplate LANGUAGES CXX)` with `project(yourlibraryname LANGUAGES CXX)`
   * Replace all instances of `cppbindingtemplate_static` with `yourlibraryname_static`
   * Replace all instances of `cppbindingtemplate_shared` with `yourlibraryname_shared` 
   * Replace all instances of `cppbindingtemplate_dotnet` with `yourlibraryname_dotnet`

3. In .NET code:
   * Replace namespace `CppBindingTemplate` with `YourLibraryName`
   * Replace `HelloWorldProvider` with your class name
   * Replace `cppbindingtemplate_dotnet` (the native library name) with `yourlibraryname_dotnet`
   * Update method names as needed

4. In project files:
   * Update package information in `YourLibraryName.csproj`:
     * `<Title>YourLibraryName</Title>`
     * `<PackageId>YourCompany.YourLibraryName</PackageId>`
     * `<Authors>your name</Authors>`
     * Update repository URLs

## Step 4: Update GitHub Actions

1. In `.github/workflows/ci.yml`:
   * Replace `CppBindingTemplate` with `YourLibraryName`
   * Update package ID from `YourName.CppBindingTemplate` to `YourCompany.YourLibraryName`
   * Update author information

## Step 5: Update README Files

1. Update `README.md` with your project description
2. Update the section in `dotnet/README.md` for your library

## Step 6: Test Your Changes

Build the project after making all changes to verify everything works correctly:

```bash
mkdir build && cd build
cmake ..
cmake --build . --config Release
cd ../dotnet
dotnet build
cd ../dotnetExample
dotnet run
```

You should see your custom "Hello World" message with platform information.

## Customizing the Functionality

Once you've renamed everything, you'll likely want to customize what your library actually does:

1. Modify the C++ header/implementation to provide your desired functionality
2. Update the .NET binding to expose your C++ functions with appropriate .NET APIs
3. Update the example to demonstrate the use of your library

Happy coding!
