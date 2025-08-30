#!/bin/bash
# This script tests the rename functionality with BamBo as the test name
# It works on macOS and Linux systems

# Set text formatting
bold=$(tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2)
red=$(tput setaf 1)
blue=$(tput setaf 4)

echo "${bold}Testing Rename Scripts${normal}"
echo "===================="

# Create a temporary directory for testing
TEST_DIR="./rename_test_$(date +%s)"
echo "Creating test directory: ${blue}${TEST_DIR}${normal}"
mkdir -p "$TEST_DIR"

# Copy all files to the test directory
echo "Copying project files..."
cp -r ./* "$TEST_DIR/" 2>/dev/null

# Enter the test directory
cd "$TEST_DIR" || { echo "${red}Failed to enter test directory${normal}"; exit 1; }

echo "${bold}Running tests...${normal}"

# Test the shell script
echo "${bold}Testing rename_project.sh:${normal}"
chmod +x ./rename_project.sh
echo -e "BamBo\nBamBoCompany\ny" | ./rename_project.sh --test

# Verify key renamed files
echo "Verifying rename results..."
if [ -f "include/bambo/bambo.h" ] && \
   [ -f "src/bambo/bambo.cpp" ] && \
   [ -f "bambo_dotnet_shim.cpp" ] && \
   grep -q "project(bambo LANGUAGES CXX)" CMakeLists.txt; then
    echo "${green}✓ Shell script test passed!${normal}"
else
    echo "${red}✗ Shell script test failed!${normal}"
fi

# Clean up the test directory
cd ..
echo "Test completed. Cleaning up..."
rm -rf "$TEST_DIR"

echo "${bold}All tests completed${normal}"
