# PowerShell script for renaming CppBindingTemplate
# Works on Windows, macOS, and Linux (with PowerShell Core installed)

param(
    [Parameter(Mandatory=$false)]
    [switch]$TestMode,
    
    [Parameter(Mandatory=$false)]
    [string]$TestLibraryName,
    
    [Parameter(Mandatory=$false)]
    [string]$TestCompanyName
)

Write-Host "CppBindingTemplate Renaming Script (Cross-Platform)" -ForegroundColor Blue -BackgroundColor Black
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# Check if running in test mode
if ($TestMode) {
    $NewLibraryName = if ($TestLibraryName) { $TestLibraryName } else { "BamBo" }
    $CompanyName = if ($TestCompanyName) { $TestCompanyName } else { "BamBoCompany" }
    
    Write-Host "Running in test mode with:" -ForegroundColor Yellow
    Write-Host "- Library Name: " -NoNewline; Write-Host $NewLibraryName -ForegroundColor Green
    Write-Host "- Company/Author: " -NoNewline; Write-Host $CompanyName -ForegroundColor Green
}
else {
    # Get user input
    $NewLibraryName = Read-Host "Enter your library name (e.g., YourLibraryName)"
    $CompanyName = Read-Host "Enter your company/author name"

    Write-Host ""
    Write-Host "You entered:"
    Write-Host "- Library Name: " -NoNewline; Write-Host $NewLibraryName -ForegroundColor Green
    Write-Host "- Company/Author: " -NoNewline; Write-Host $CompanyName -ForegroundColor Green
    Write-Host ""

    $confirm = Read-Host "Is this correct? (y/n)"
    if ($confirm -notmatch '^[Yy]$') {
        Write-Host "Operation cancelled." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Starting renaming process..." -ForegroundColor Cyan
Write-Host ""

# Convert library name to lowercase for certain replacements
$LowerLibraryName = $NewLibraryName.ToLower()

Write-Host "Step 1: Renaming directories..." -ForegroundColor Yellow
# Create new directories
if (!(Test-Path "include/$LowerLibraryName")) {
    New-Item -Path "include/$LowerLibraryName" -ItemType Directory -Force | Out-Null
}

if (!(Test-Path "src/$LowerLibraryName")) {
    New-Item -Path "src/$LowerLibraryName" -ItemType Directory -Force | Out-Null
}

# Copy files to new directories
Copy-Item -Path "include/cppbindingtemplate/*" -Destination "include/$LowerLibraryName/" -Force
Copy-Item -Path "src/cppbindingtemplate/*" -Destination "src/$LowerLibraryName/" -Force

Write-Host "Step 2: Renaming files..." -ForegroundColor Yellow
# Rename files in the new directories
Rename-Item -Path "include/$LowerLibraryName/cppbindingtemplate.h" -NewName "$LowerLibraryName.h"
Rename-Item -Path "src/$LowerLibraryName/cppbindingtemplate.cpp" -NewName "$LowerLibraryName.cpp"
Copy-Item -Path "cppbindingtemplate_dotnet_shim.cpp" -Destination "$LowerLibraryName`_dotnet_shim.cpp" -Force
Copy-Item -Path "dotnet/CppBindingTemplate.csproj" -Destination "dotnet/$NewLibraryName.csproj" -Force
Copy-Item -Path "dotnet/CppBindingTemplate.sln" -Destination "dotnet/$NewLibraryName.sln" -Force
Copy-Item -Path "dotnet/HelloWorldProvider.cs" -Destination "dotnet/$($NewLibraryName)Provider.cs" -Force

Write-Host "Step 3: Updating file contents..." -ForegroundColor Yellow

Write-Host "  Updating C++ header..."
(Get-Content -Path "include/$LowerLibraryName/$LowerLibraryName.h") | 
    ForEach-Object { 
        $_ -replace 'cppbindingtemplate', $LowerLibraryName -replace 'CppBindingTemplate', $NewLibraryName 
    } | Set-Content -Path "include/$LowerLibraryName/$LowerLibraryName.h"

Write-Host "  Updating C++ source..."
(Get-Content -Path "src/$LowerLibraryName/$LowerLibraryName.cpp") | 
    ForEach-Object { 
        $_ -replace 'cppbindingtemplate/cppbindingtemplate\.h', "$LowerLibraryName/$LowerLibraryName.h" -replace 'cppbindingtemplate', $LowerLibraryName -replace 'CppBindingTemplate', $NewLibraryName 
    } | Set-Content -Path "src/$LowerLibraryName/$LowerLibraryName.cpp"

Write-Host "  Updating dotnet shim..."
(Get-Content -Path "$LowerLibraryName`_dotnet_shim.cpp") | 
    ForEach-Object { 
        $_ -replace 'cppbindingtemplate/cppbindingtemplate\.h', "$LowerLibraryName/$LowerLibraryName.h" -replace 'cppbindingtemplate', $LowerLibraryName -replace 'CppBindingTemplate', $NewLibraryName 
    } | Set-Content -Path "$LowerLibraryName`_dotnet_shim.cpp"

Write-Host "  Updating CMakeLists.txt..."
(Get-Content -Path "CMakeLists.txt") | 
    ForEach-Object { 
        $_ -replace 'project\(cppbindingtemplate', "project($LowerLibraryName" -replace 'cppbindingtemplate_static', "$($LowerLibraryName)_static" -replace 'cppbindingtemplate_shared', "$($LowerLibraryName)_shared" -replace 'cppbindingtemplate_dotnet', "$($LowerLibraryName)_dotnet" 
    } | Set-Content -Path "CMakeLists.txt"

Write-Host "  Updating .NET project files..."
(Get-Content -Path "dotnet/$NewLibraryName.csproj") | 
    ForEach-Object { 
        $_ -replace 'CppBindingTemplate', $NewLibraryName -replace '<Title>.*</Title>', "<Title>$NewLibraryName</Title>" -replace '<PackageId>YourName\.CppBindingTemplate</PackageId>', "<PackageId>$CompanyName.$NewLibraryName</PackageId>" -replace '<Authors>.*</Authors>', "<Authors>$CompanyName</Authors>" -replace 'cppbindingtemplate_dotnet', "$($LowerLibraryName)_dotnet" 
    } | Set-Content -Path "dotnet/$NewLibraryName.csproj"

(Get-Content -Path "dotnet/$NewLibraryName.sln") | 
    ForEach-Object { 
        $_ -replace 'CppBindingTemplate', $NewLibraryName 
    } | Set-Content -Path "dotnet/$NewLibraryName.sln"

Write-Host "  Updating .NET provider..."
(Get-Content -Path "dotnet/$($NewLibraryName)Provider.cs") | 
    ForEach-Object { 
        $_ -replace 'namespace CppBindingTemplate', "namespace $NewLibraryName" -replace 'HelloWorldProvider', "$($NewLibraryName)Provider" -replace 'cppbindingtemplate_dotnet', "$($LowerLibraryName)_dotnet" 
    } | Set-Content -Path "dotnet/$($NewLibraryName)Provider.cs"

Write-Host "  Updating NativeLibrary.cs..."
(Get-Content -Path "dotnet/NativeLibrary.cs") | 
    ForEach-Object { 
        $_ -replace 'namespace CppBindingTemplate', "namespace $NewLibraryName" -replace 'cppbindingtemplate_dotnet', "$($LowerLibraryName)_dotnet" 
    } | Set-Content -Path "dotnet/NativeLibrary.cs"

Write-Host "  Updating dotnetExample..."
(Get-Content -Path "dotnetExample/Program.cs") | 
    ForEach-Object { 
        $_ -replace 'CppBindingTemplate', $NewLibraryName -replace 'HelloWorldProvider', "$($NewLibraryName)Provider" 
    } | Set-Content -Path "dotnetExample/Program.cs"

(Get-Content -Path "dotnetExample/Example.csproj") | 
    ForEach-Object { 
        $_ -replace 'CppBindingTemplate', $NewLibraryName -replace 'YourName\.CppBindingTemplate', "$CompanyName.$NewLibraryName" 
    } | Set-Content -Path "dotnetExample/Example.csproj"

Write-Host "Step 4: Cleaning up original files..." -ForegroundColor Yellow
Remove-Item -Path "include/cppbindingtemplate" -Recurse -Force
Remove-Item -Path "src/cppbindingtemplate" -Recurse -Force
Remove-Item -Path "cppbindingtemplate_dotnet_shim.cpp" -Force
Remove-Item -Path "dotnet/CppBindingTemplate.csproj" -Force
Remove-Item -Path "dotnet/CppBindingTemplate.sln" -Force
Remove-Item -Path "dotnet/HelloWorldProvider.cs" -Force

Write-Host ""
Write-Host "Renaming complete! Your library is now named $NewLibraryName." -ForegroundColor Green
Write-Host ""
Write-Host "Please review the changes carefully and update any additional files or references as needed."
Write-Host "Don't forget to update README.md files with your project information."
Write-Host ""
Write-Host "To test your changes, run:"
Write-Host "  mkdir build && cd build"
Write-Host "  cmake .."
Write-Host "  cmake --build . --config Release"
Write-Host "  cd ../dotnet"
Write-Host "  dotnet build"
Write-Host "  cd ../dotnetExample"
Write-Host "  dotnet run"
Write-Host ""
