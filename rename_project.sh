#!/bin/bash

# Set text formatting
bold=$(tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2)
red=$(tput setaf 1)

echo "${bold}CppBindingTemplate Renaming Script (macOS/Linux)${normal}"
echo "==========================================="
echo

# Check if running in test mode
TEST_MODE=0
if [[ "$1" == "--test" ]]; then
    TEST_MODE=1
    NewLibraryName="BamBo"
    CompanyName="BamBoCompany"
    echo "Running in test mode with library name: ${green}${NewLibraryName}${normal}"
    echo "Company name: ${green}${CompanyName}${normal}"
else
    # Get user input
    read -p "Enter your library name (e.g., YourLibraryName): " NewLibraryName
    read -p "Enter your company/author name: " CompanyName

    echo
    echo "You entered:"
    echo "- Library Name: ${green}${NewLibraryName}${normal}"
    echo "- Company/Author: ${green}${CompanyName}${normal}"
    echo

    read -p "Is this correct? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "${red}Operation cancelled.${normal}"
        exit 1
    fi
fi

echo
echo "Starting renaming process..."
echo

# Convert library name to lowercase for certain replacements
LowerLibraryName=$(echo "$NewLibraryName" | tr '[:upper:]' '[:lower:]')

echo "Step 1: Renaming directories..."
mkdir -p "include/$LowerLibraryName"
mkdir -p "src/$LowerLibraryName"

# Copy files to new directories first, then we'll update content
cp -r include/cppbindingtemplate/* "include/$LowerLibraryName/"
cp -r src/cppbindingtemplate/* "src/$LowerLibraryName/"

echo "Step 2: Renaming files..."
mv "include/$LowerLibraryName/cppbindingtemplate.h" "include/$LowerLibraryName/$LowerLibraryName.h"
mv "src/$LowerLibraryName/cppbindingtemplate.cpp" "src/$LowerLibraryName/$LowerLibraryName.cpp"
cp cppbindingtemplate_dotnet_shim.cpp "${LowerLibraryName}_dotnet_shim.cpp"
cp dotnet/CppBindingTemplate.csproj "dotnet/$NewLibraryName.csproj"
cp dotnet/CppBindingTemplate.sln "dotnet/$NewLibraryName.sln"
cp dotnet/HelloWorldProvider.cs "dotnet/${NewLibraryName}Provider.cs"

echo "Step 3: Updating file contents..."

echo "Updating C++ header..."
sed -i.bak \
    -e "s/cppbindingtemplate/$LowerLibraryName/g" \
    -e "s/CppBindingTemplate/$NewLibraryName/g" \
    "include/$LowerLibraryName/$LowerLibraryName.h"

echo "Updating C++ source..."
sed -i.bak \
    -e "s|cppbindingtemplate/cppbindingtemplate\.h|$LowerLibraryName/$LowerLibraryName.h|g" \
    -e "s/cppbindingtemplate/$LowerLibraryName/g" \
    -e "s/CppBindingTemplate/$NewLibraryName/g" \
    "src/$LowerLibraryName/$LowerLibraryName.cpp"

echo "Updating dotnet shim..."
sed -i.bak \
    -e "s|cppbindingtemplate/cppbindingtemplate\.h|$LowerLibraryName/$LowerLibraryName.h|g" \
    -e "s/cppbindingtemplate/$LowerLibraryName/g" \
    -e "s/CppBindingTemplate/$NewLibraryName/g" \
    "${LowerLibraryName}_dotnet_shim.cpp"

echo "Updating CMakeLists.txt..."
sed -i.bak \
    -e "s/project(cppbindingtemplate/project($LowerLibraryName/g" \
    -e "s/cppbindingtemplate_static/${LowerLibraryName}_static/g" \
    -e "s/cppbindingtemplate_shared/${LowerLibraryName}_shared/g" \
    -e "s/cppbindingtemplate_dotnet/${LowerLibraryName}_dotnet/g" \
    CMakeLists.txt

echo "Updating .NET project files..."
sed -i.bak \
    -e "s/CppBindingTemplate/$NewLibraryName/g" \
    -e "s|<Title>.*</Title>|<Title>$NewLibraryName</Title>|g" \
    -e "s|<PackageId>YourName\.CppBindingTemplate</PackageId>|<PackageId>$CompanyName.$NewLibraryName</PackageId>|g" \
    -e "s|<Authors>.*</Authors>|<Authors>$CompanyName</Authors>|g" \
    -e "s/cppbindingtemplate_dotnet/${LowerLibraryName}_dotnet/g" \
    "dotnet/$NewLibraryName.csproj"

sed -i.bak \
    -e "s/CppBindingTemplate/$NewLibraryName/g" \
    "dotnet/$NewLibraryName.sln"

echo "Updating .NET provider..."
sed -i.bak \
    -e "s/namespace CppBindingTemplate/namespace $NewLibraryName/g" \
    -e "s/HelloWorldProvider/${NewLibraryName}Provider/g" \
    -e "s/cppbindingtemplate_dotnet/${LowerLibraryName}_dotnet/g" \
    "dotnet/${NewLibraryName}Provider.cs"

echo "Updating NativeLibrary.cs..."
sed -i.bak \
    -e "s/namespace CppBindingTemplate/namespace $NewLibraryName/g" \
    -e "s/cppbindingtemplate_dotnet/${LowerLibraryName}_dotnet/g" \
    "dotnet/NativeLibrary.cs"

echo "Updating dotnetExample..."
sed -i.bak \
    -e "s/CppBindingTemplate/$NewLibraryName/g" \
    -e "s/HelloWorldProvider/${NewLibraryName}Provider/g" \
    "dotnetExample/Program.cs"

sed -i.bak \
    -e "s/CppBindingTemplate/$NewLibraryName/g" \
    -e "s/YourName\.CppBindingTemplate/$CompanyName.$NewLibraryName/g" \
    "dotnetExample/Example.csproj"

echo "Cleaning up backup files..."
find . -name "*.bak" -delete

echo "Step 4: Cleaning up original files..."
rm -rf include/cppbindingtemplate
rm -rf src/cppbindingtemplate
rm -f cppbindingtemplate_dotnet_shim.cpp
rm -f dotnet/CppBindingTemplate.csproj
rm -f dotnet/CppBindingTemplate.sln
rm -f dotnet/HelloWorldProvider.cs

echo
echo "${bold}${green}Renaming complete! Your library is now named $NewLibraryName.${normal}"
echo
echo "Please review the changes carefully and update any additional files or references as needed."
echo "Don't forget to update README.md files with your project information."
echo
echo "To test your changes, run:"
echo "  mkdir build && cd build"
echo "  cmake .."
echo "  cmake --build . --config Release"
echo "  cd ../dotnet"
echo "  dotnet build"
echo "  cd ../dotnetExample"
echo "  dotnet run"
echo
