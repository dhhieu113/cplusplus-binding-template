@echo off
setlocal EnableDelayedExpansion

echo CppBindingTemplate Renaming Script (Windows)
echo =========================================

REM Check if running in test mode
set "TestMode=0"
if "%~1"=="-test" (
    set "TestMode=1"
    set "NewLibraryName=BamBo"
    set "CompanyName=BamBoCompany"
    echo Running in test mode with library name: %NewLibraryName%
    echo Company name: %CompanyName%
    goto :skipInput
)

set /p "NewLibraryName=Enter your library name (e.g., YourLibraryName): "
set /p "CompanyName=Enter your company/author name: "

echo.
echo You entered:
echo - Library Name: %NewLibraryName%
echo - Company/Author: %CompanyName%
echo.

set /p "confirm=Is this correct? (y/n): "
if /i not "%confirm%"=="y" (
    echo Operation cancelled.
    exit /b 1
)

:skipInput
echo.
echo Starting renaming process...
echo.

REM Convert library name to lowercase for certain replacements
set "LowerLibraryName=%NewLibraryName%"
powershell -Command "$str='%LowerLibraryName%'; $result=$str.ToLower(); Write-Output $result" > temp.txt
set /p LowerLibraryName=<temp.txt
del temp.txt

echo Step 1: Renaming directories...
if not exist include\%LowerLibraryName% mkdir include\%LowerLibraryName%
if not exist src\%LowerLibraryName% mkdir src\%LowerLibraryName%

REM Copy files to new directories first, then we'll update content
xcopy /y include\cppbindingtemplate\*.* include\%LowerLibraryName%\
xcopy /y src\cppbindingtemplate\*.* src\%LowerLibraryName%\

echo Step 2: Renaming files...
ren include\%LowerLibraryName%\cppbindingtemplate.h %LowerLibraryName%.h
ren src\%LowerLibraryName%\cppbindingtemplate.cpp %LowerLibraryName%.cpp
copy cppbindingtemplate_dotnet_shim.cpp %LowerLibraryName%_dotnet_shim.cpp
copy dotnet\CppBindingTemplate.csproj dotnet\%NewLibraryName%.csproj
copy dotnet\CppBindingTemplate.sln dotnet\%NewLibraryName%.sln
copy dotnet\HelloWorldProvider.cs dotnet\%NewLibraryName%Provider.cs

echo Step 3: Updating file contents...

echo Updating C++ header...
powershell -Command "(Get-Content include\%LowerLibraryName%\%LowerLibraryName%.h) | ForEach-Object { $_ -replace 'cppbindingtemplate', '%LowerLibraryName%' -replace 'CppBindingTemplate', '%NewLibraryName%' } | Set-Content include\%LowerLibraryName%\%LowerLibraryName%.h"

echo Updating C++ source...
powershell -Command "(Get-Content src\%LowerLibraryName%\%LowerLibraryName%.cpp) | ForEach-Object { $_ -replace 'cppbindingtemplate\/cppbindingtemplate\.h', '%LowerLibraryName%/%LowerLibraryName%.h' -replace 'cppbindingtemplate', '%LowerLibraryName%' -replace 'CppBindingTemplate', '%NewLibraryName%' } | Set-Content src\%LowerLibraryName%\%LowerLibraryName%.cpp"

echo Updating dotnet shim...
powershell -Command "(Get-Content %LowerLibraryName%_dotnet_shim.cpp) | ForEach-Object { $_ -replace 'cppbindingtemplate\/cppbindingtemplate\.h', '%LowerLibraryName%/%LowerLibraryName%.h' -replace 'cppbindingtemplate', '%LowerLibraryName%' -replace 'CppBindingTemplate', '%NewLibraryName%' } | Set-Content %LowerLibraryName%_dotnet_shim.cpp"

echo Updating CMakeLists.txt...
powershell -Command "(Get-Content CMakeLists.txt) | ForEach-Object { $_ -replace 'project\(cppbindingtemplate', 'project(%LowerLibraryName%' -replace 'cppbindingtemplate_static', '%LowerLibraryName%_static' -replace 'cppbindingtemplate_shared', '%LowerLibraryName%_shared' -replace 'cppbindingtemplate_dotnet', '%LowerLibraryName%_dotnet' } | Set-Content CMakeLists.txt"

echo Updating .NET project files...
powershell -Command "(Get-Content dotnet\%NewLibraryName%.csproj) | ForEach-Object { $_ -replace 'CppBindingTemplate', '%NewLibraryName%' -replace '<Title>.*</Title>', '<Title>%NewLibraryName%</Title>' -replace '<PackageId>YourName\.CppBindingTemplate</PackageId>', '<PackageId>%CompanyName%.%NewLibraryName%</PackageId>' -replace '<Authors>.*</Authors>', '<Authors>%CompanyName%</Authors>' -replace 'cppbindingtemplate_dotnet', '%LowerLibraryName%_dotnet' } | Set-Content dotnet\%NewLibraryName%.csproj"

powershell -Command "(Get-Content dotnet\%NewLibraryName%.sln) | ForEach-Object { $_ -replace 'CppBindingTemplate', '%NewLibraryName%' } | Set-Content dotnet\%NewLibraryName%.sln"

echo Updating .NET provider...
powershell -Command "(Get-Content dotnet\%NewLibraryName%Provider.cs) | ForEach-Object { $_ -replace 'namespace CppBindingTemplate', 'namespace %NewLibraryName%' -replace 'HelloWorldProvider', '%NewLibraryName%Provider' -replace 'cppbindingtemplate_dotnet', '%LowerLibraryName%_dotnet' } | Set-Content dotnet\%NewLibraryName%Provider.cs"

echo Updating NativeLibrary.cs...
powershell -Command "(Get-Content dotnet\NativeLibrary.cs) | ForEach-Object { $_ -replace 'namespace CppBindingTemplate', 'namespace %NewLibraryName%' -replace 'cppbindingtemplate_dotnet', '%LowerLibraryName%_dotnet' } | Set-Content dotnet\NativeLibrary.cs"

echo Updating dotnetExample...
powershell -Command "(Get-Content dotnetExample\Program.cs) | ForEach-Object { $_ -replace 'CppBindingTemplate', '%NewLibraryName%' -replace 'HelloWorldProvider', '%NewLibraryName%Provider' } | Set-Content dotnetExample\Program.cs"

powershell -Command "(Get-Content dotnetExample\Example.csproj) | ForEach-Object { $_ -replace 'CppBindingTemplate', '%NewLibraryName%' -replace 'YourName\.CppBindingTemplate', '%CompanyName%.%NewLibraryName%' } | Set-Content dotnetExample\Example.csproj"

echo Step 4: Cleaning up original files...
rmdir /s /q include\cppbindingtemplate
rmdir /s /q src\cppbindingtemplate
del cppbindingtemplate_dotnet_shim.cpp
del dotnet\CppBindingTemplate.csproj
del dotnet\CppBindingTemplate.sln
del dotnet\HelloWorldProvider.cs

echo.
echo Renaming complete! Your library is now named %NewLibraryName%.
echo.
echo Please review the changes carefully and update any additional files or references as needed.
echo Don't forget to update README.md files with your project information.
echo.
echo To test your changes, run:
echo   mkdir build ^&^& cd build
echo   cmake ..
echo   cmake --build . --config Release
echo   cd ../dotnet
echo   dotnet build
echo   cd ../dotnetExample
echo   dotnet run
echo.

endlocal
