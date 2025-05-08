# install.ps1
# Installation script for PokemonFetch for Windows

# Ensure we're running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script isn't running as Administrator. Some operations might fail."
    Write-Host "For best results, run this script as Administrator."
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit
    }
}

# Define installation location
$install_dir = "$env:USERPROFILE\pokemonfetch-windows"

# Check if the installation directory already exists
if (Test-Path -Path $install_dir) {
    Write-Host "Installation directory already exists: $install_dir" -ForegroundColor Yellow
    $overwrite = Read-Host "Overwrite? (y/n)"
    if ($overwrite -eq "y") {
        Remove-Item -Path $install_dir -Recurse -Force
    } else {
        Write-Host "Installation aborted."
        exit
    }
}

# Get the current script directory
$script_path = $MyInvocation.MyCommand.Path
$script_dir = Split-Path -Parent $script_path

# Create the installation directory
Write-Host "Creating installation directory: $install_dir" -ForegroundColor Green
New-Item -Path $install_dir -ItemType Directory -Force | Out-Null

# Copy files
Write-Host "Copying files..." -ForegroundColor Green
Copy-Item -Path "$script_dir\pokemonfetch.ps1" -Destination "$install_dir\" -Force
Copy-Item -Path "$script_dir\README.md" -Destination "$install_dir\" -Force
Copy-Item -Path "$script_dir\profile-setup.ps1" -Destination "$install_dir\" -Force
Copy-Item -Path "$script_dir\enable-ansi.ps1" -Destination "$install_dir\" -Force

# Create cows directory and copy all cow files
$cows_dir = "$install_dir\cows"
New-Item -Path $cows_dir -ItemType Directory -Force | Out-Null

# Check if source cows directory exists
if (Test-Path -Path "$script_dir\cows") {
    # Copy cow files
    Copy-Item -Path "$script_dir\cows\*.cow" -Destination "$cows_dir\" -Force
    Write-Host "Copied Pokémon ASCII art files." -ForegroundColor Green
} else {
    Write-Host "Warning: Cows directory not found. You'll need to manually add .cow files to $cows_dir" -ForegroundColor Yellow
}

# Check ANSI support
Write-Host "Checking ANSI escape sequence support..." -ForegroundColor Green
& "$install_dir\enable-ansi.ps1"

# Run profile setup
Write-Host "Setting up PowerShell profile..." -ForegroundColor Green
& "$install_dir\profile-setup.ps1"

Write-Host @"

Installation completed!

PokemonFetch has been installed to: $install_dir
It will now run automatically when you start PowerShell.

To run it manually, use:
& '$install_dir\pokemonfetch.ps1'

"@ -ForegroundColor Cyan

# Ask if user wants to run now
$run_now = Read-Host "Would you like to run PokemonFetch now? (y/n)"
if ($run_now -eq "y") {
    & "$install_dir\pokemonfetch.ps1"
} 