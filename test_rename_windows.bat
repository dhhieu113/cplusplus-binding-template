@echo off
setlocal EnableDelayedExpansion

echo Testing Rename Scripts
echo ====================

:: Create a temporary directory for testing
set TEST_DIR=.\rename_test_%RANDOM%
echo Creating test directory: %TEST_DIR%
mkdir "%TEST_DIR%" 2>nul

:: Copy all files to the test directory
echo Copying project files...
xcopy /E /I /Q /Y .\ "%TEST_DIR%\" >nul

:: Enter the test directory
cd "%TEST_DIR%" || (echo Failed to enter test directory & exit /b 1)

echo Running tests...

:: Test the batch script
echo Testing rename_project.bat:
echo BamBo | call rename_project.bat -test

:: Verify key renamed files
echo Verifying rename results...
if exist "include\bambo\bambo.h" (
    if exist "src\bambo\bambo.cpp" (
        if exist "bambo_dotnet_shim.cpp" (
            findstr /C:"project(bambo LANGUAGES CXX)" CMakeLists.txt >nul
            if !errorlevel! equ 0 (
                echo [92m✓ Batch script test passed![0m
            ) else (
                echo [91m✗ Batch script test failed! CMakeLists.txt not updated correctly[0m
            )
        ) else (
            echo [91m✗ Batch script test failed! Shim file not renamed[0m
        )
    ) else (
        echo [91m✗ Batch script test failed! Source file not renamed[0m
    )
) else (
    echo [91m✗ Batch script test failed! Header file not renamed[0m
)

:: Test the PowerShell script
echo.
echo Testing rename_project.ps1:
powershell -Command "& { .\rename_project.ps1 -TestMode -TestLibraryName 'BamBo' -TestCompanyName 'BamBoCompany' }"

:: Verify key renamed files
echo Verifying rename results...
if exist "include\bambo\bambo.h" (
    if exist "src\bambo\bambo.cpp" (
        if exist "bambo_dotnet_shim.cpp" (
            findstr /C:"project(bambo LANGUAGES CXX)" CMakeLists.txt >nul
            if !errorlevel! equ 0 (
                echo [92m✓ PowerShell script test passed![0m
            ) else (
                echo [91m✗ PowerShell script test failed! CMakeLists.txt not updated correctly[0m
            )
        ) else (
            echo [91m✗ PowerShell script test failed! Shim file not renamed[0m
        )
    ) else (
        echo [91m✗ PowerShell script test failed! Source file not renamed[0m
    )
) else (
    echo [91m✗ PowerShell script test failed! Header file not renamed[0m
)

:: Clean up the test directory
cd ..
echo Test completed. Cleaning up...
rmdir /s /q "%TEST_DIR%"

echo All tests completed

endlocal
