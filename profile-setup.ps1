# profile-setup.ps1
# This script sets up pokemonfetch to run on PowerShell startup

# Get the current script directory
$script_path = $MyInvocation.MyCommand.Path
$script_dir = Split-Path -Parent $script_path

# Verify if the script exists
$pokemonfetch_path = Join-Path -Path $script_dir -ChildPath "pokemonfetch.ps1"
if (-not (Test-Path -Path $pokemonfetch_path)) {
    Write-Error "pokemonfetch.ps1 not found at $pokemonfetch_path"
    exit 1
}

# Get PowerShell profile path
$profile_path = $PROFILE.CurrentUserAllHosts
$profile_dir = Split-Path -Parent $profile_path

# Create profile directory if it doesn't exist
if (-not (Test-Path -Path $profile_dir)) {
    New-Item -Path $profile_dir -ItemType Directory -Force | Out-Null
    Write-Host "Created profile directory: $profile_dir"
}

# Check if profile exists
if (-not (Test-Path -Path $profile_path)) {
    New-Item -Path $profile_path -ItemType File -Force | Out-Null
    Write-Host "Created new PowerShell profile: $profile_path"
}

# Check if pokemonfetch is already in the profile
$profile_content = Get-Content -Path $profile_path -Raw -ErrorAction SilentlyContinue
if ($profile_content -and $profile_content.Contains("pokemonfetch")) {
    Write-Host "Pokemonfetch is already in your PowerShell profile."
} else {
    # Add pokemonfetch to profile
    $pokemonfetch_command = "`n# Run pokemonfetch on startup`n& '$pokemonfetch_path'"
    Add-Content -Path $profile_path -Value $pokemonfetch_command
    Write-Host "Added pokemonfetch to your PowerShell profile."
}

# Display instructions
Write-Host @"

Setup completed!
Pokemonfetch will now run whenever you start PowerShell.

To test it right now, restart your PowerShell session or run:
& '$pokemonfetch_path'

"@ 