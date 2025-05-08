# enable-ansi.ps1
# This script checks and enables ANSI escape sequence support in Windows PowerShell

function Test-ANSISupport {
    # Test if ANSI escape sequences work
    $test_str = "`e[31mRED`e[0m"
    Write-Host ""
    Write-Host "Testing ANSI support..."
    Write-Host $test_str
    Write-Host ""

    $result = Read-Host "Did you see 'RED' in red color? (y/n)"
    return $result -eq "y"
}

function Enable-ANSISupport {
    # For Windows PowerShell, try to enable VirtualTerminalProcessing
    if ($PSVersionTable.PSEdition -eq "Desktop" -or $PSVersionTable.PSVersion.Major -lt 6) {
        try {
            $CONSOLE = Get-ItemProperty "HKCU:\Console"
            # Check if VirtualTerminalLevel exists and is 1
            if (-not ($CONSOLE.VirtualTerminalLevel -eq 1)) {
                Write-Host "Enabling ANSI support in registry..." -ForegroundColor Yellow
                Set-ItemProperty "HKCU:\Console" -Name "VirtualTerminalLevel" -Value 1 -Type DWORD
                Write-Host "ANSI support enabled. You need to restart your PowerShell session." -ForegroundColor Green
                return $false
            }
        } catch {
            Write-Warning "Failed to check or modify registry: $_"
        }
    }
    
    # For PowerShell Core, ANSI support is built-in
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        Write-Host "PowerShell Core detected, ANSI support should be available by default." -ForegroundColor Green
        return $true
    }

    return $false
}

function Enable-PowerShellProfile {
    # Create or update PowerShell profile to enable ANSI support on startup
    $profile_content = @"
# Enable ANSI escape sequences
`$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

# This makes ANSI colors work in Windows PowerShell
if (`$PSVersionTable.PSEdition -eq "Desktop" -or `$PSVersionTable.PSVersion.Major -lt 6) {
    `$Host.UI.RawUI.WindowTitle = "PokemonFetch PowerShell"
    
    # Try to enable VirtualTerminalProcessing via .NET as a fallback
    # This works within the current session without admin rights
    try {
        `$signature = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, int mode);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr handle, out int mode);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int handle);
'@

        `$type = Add-Type -MemberDefinition `$signature -Name Win32ConsoleMode -Namespace Win32Functions -PassThru
        `$handle = `$type::GetStdHandle(-11) # STD_OUTPUT_HANDLE
        `$mode = 0
        `$type::GetConsoleMode(`$handle, [ref]`$mode)
        `$mode = `$mode -bor 4 # ENABLE_VIRTUAL_TERMINAL_PROCESSING
        `$type::SetConsoleMode(`$handle, `$mode)
    } catch {
        # Silently continue if this fails
    }
}
"@

    # Get PowerShell profile path for the current user
    $profile_path = $PROFILE.CurrentUserAllHosts
    $profile_dir = Split-Path -Parent $profile_path

    # Create profile directory if it doesn't exist
    if (-not (Test-Path -Path $profile_dir)) {
        New-Item -Path $profile_dir -ItemType Directory -Force | Out-Null
    }

    # Check if profile exists and create/modify it
    if (Test-Path -Path $profile_path) {
        $current_profile = Get-Content -Path $profile_path -Raw -ErrorAction SilentlyContinue
        if ($current_profile -and $current_profile.Contains("ENABLE_VIRTUAL_TERMINAL_PROCESSING")) {
            Write-Host "ANSI support code is already in your PowerShell profile." -ForegroundColor Green
        } else {
            # Backup existing profile
            Copy-Item -Path $profile_path -Destination "$profile_path.bak" -Force
            Write-Host "Backed up existing profile to $profile_path.bak" -ForegroundColor Yellow
            
            # Add ANSI enabling code to the beginning of the profile
            $new_profile = $profile_content + "`n`n" + $current_profile
            Set-Content -Path $profile_path -Value $new_profile
            Write-Host "Updated PowerShell profile with ANSI support code." -ForegroundColor Green
        }
    } else {
        # Create new profile with ANSI support
        Set-Content -Path $profile_path -Value $profile_content
        Write-Host "Created new PowerShell profile with ANSI support code." -ForegroundColor Green
    }
}

# Main script
Write-Host "PokemonFetch ANSI Support Tool" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script checks and enables support for ANSI color codes,"
Write-Host "which are required for PokemonFetch to display properly."

# Check current PowerShell version
Write-Host ""
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
Write-Host "PS Edition: $($PSVersionTable.PSEdition)" -ForegroundColor Cyan

# Test ANSI support
$ansi_works = Test-ANSISupport

if ($ansi_works) {
    Write-Host "ANSI escape sequences are working correctly!" -ForegroundColor Green
} else {
    Write-Host "ANSI escape sequences are not working properly." -ForegroundColor Yellow
    
    # Try to enable ANSI support
    $enabled = Enable-ANSISupport
    
    if (-not $enabled) {
        # Add to PowerShell profile for future sessions
        Write-Host ""
        Write-Host "Adding ANSI support code to your PowerShell profile." -ForegroundColor Yellow
        Enable-PowerShellProfile
        
        Write-Host ""
        Write-Host "You need to restart your PowerShell session for changes to take effect." -ForegroundColor Yellow
        Write-Host "After restarting, please run this script again to verify ANSI support." -ForegroundColor Yellow
    }
}

# Recommend Windows Terminal
if ($env:WT_SESSION) {
    Write-Host ""
    Write-Host "You're using Windows Terminal, which has excellent ANSI support. Perfect!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Recommended: Use Windows Terminal for the best experience with PokemonFetch." -ForegroundColor Yellow
    Write-Host "You can download it from the Microsoft Store or GitHub: https://github.com/microsoft/terminal" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 