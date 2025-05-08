# pokemonfetch.ps1
# A PowerShell version of pokemonfetch for Windows

# ANSI Color codes
$reset = "`e[0m"
$title_color = "`e[38;5;209m"
$info_color = "`e[38;5;75m"

# Get script directory for finding cow files
$script_path = $MyInvocation.MyCommand.Path
$script_dir = Split-Path -Parent $script_path
$cows_dir = Join-Path -Path $script_dir -ChildPath "cows"

# Define column width for formatting
$W = 40
$H = 22
$SHIFT_COL = "`e[${W}C"

# Function to get a random Pokémon cow file
function Get-RandomPokemon {
    $pokemon_files = Get-ChildItem -Path $cows_dir -Filter "*.cow"
    $random_pokemon = $pokemon_files | Get-Random
    $pokemon_content = Get-Content -Path $random_pokemon.FullName
    $pokemon_name = $random_pokemon.BaseName
    
    return @{
        Content = $pokemon_content
        Name = $pokemon_name
    }
}

# Function to display the Pokémon
function Show-Pokemon {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$Pokemon,
        [Parameter()]
        [bool]$IsThinking = $false
    )
    
    $pokemon_content = $Pokemon.Content
    $pokemon_name = $Pokemon.Name
    
    # Calculate width of the Pokémon for centering the name
    $pokemon_width = ($pokemon_content | Measure-Object -Property Length -Maximum).Maximum
    
    # Display the Pokémon
    Write-Host ""
    foreach ($line in $pokemon_content) {
        Write-Host $line
    }
    
    # Center and display the Pokémon name with a bubble
    $name_to_display = $Pokemon.Name
    $bubble_name = ""
    if ($IsThinking) {
        $bubble_name = "o ( $($name_to_display) ) O" # Think bubble
    } else {
        $bubble_name = "( $($name_to_display) )"   # Say bubble
    }

    $padding = [math]::Floor(($pokemon_width - $bubble_name.Length) / 2)
    if ($padding -lt 0) { $padding = 0 } # Ensure padding isn't negative
    $padding_str = " " * $padding
    Write-Host "$padding_str$bubble_name"
    
    # Move cursor up to start of Pokémon for side-by-side display
    Write-Host "`e[${H}A" -NoNewline
}

# Function to get system information
function Get-SystemInfo {
    # Get OS info
    $os = (Get-CimInstance -ClassName Win32_OperatingSystem)
    $os_name = $os.Caption
    $os_version = $os.Version
    
    # Get hostname
    $hostname = $env:COMPUTERNAME
    $username = $env:USERNAME
    $title = "$username@$hostname"
    
    # Get uptime
    $uptime = (Get-Date) - $os.LastBootUpTime
    $uptime_str = ""
    if ($uptime.Days -gt 0) { $uptime_str += "$($uptime.Days) days, " }
    $uptime_str += "$($uptime.Hours) hours, $($uptime.Minutes) mins"
    
    # Get kernel version
    $kernel = $os.Version
    
    # Get CPU info
    $cpu = (Get-CimInstance -ClassName Win32_Processor).Name
    
    # Get memory
    $memory = Get-CimInstance -ClassName Win32_OperatingSystem
    $memory_total = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $memory_free = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
    $memory_used = [math]::Round($memory_total - $memory_free, 2)
    $memory_str = "$memory_used GB / $memory_total GB"
    
    # Get disk info
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
    $disk_total = [math]::Round($disk.Size / 1GB, 2)
    $disk_free = [math]::Round($disk.FreeSpace / 1GB, 2)
    $disk_used = [math]::Round($disk_total - $disk_free, 2)
    $disk_str = "$disk_used GB / $disk_total GB"
    
    # Get shell info
    $shell = (Get-Process -Id $PID).MainModule.FileName
    $shell_version = $PSVersionTable.PSVersion.ToString()
    
    # Get resolution
    $resolution = Get-CimInstance -ClassName Win32_VideoController | ForEach-Object { "$($_.CurrentHorizontalResolution) x $($_.CurrentVerticalResolution)" }
    
    # Get GPU info
    $allGpus = Get-CimInstance -ClassName Win32_VideoController
    $gpuName = "N/A" # Default if no suitable GPU is found

    if ($allGpus) {
        # Filter out known virtual/USB/problematic adapters by name first, and only consider working devices
        $candidateGpus = $allGpus | Where-Object { 
            $_.Name -notmatch "DisplayLink" -and 
            $_.Name -notmatch "Microsoft Basic Display Adapter" -and
            $_.Name -notmatch "Remote Display Adapter" -and
            $_.Status -eq "OK"
        }

        # If filtering removed everything relevant, consider all working GPUs from the original list
        if (-not $candidateGpus -and ($allGpus | Where-Object {$_.Status -eq "OK"})) {
            $candidateGpus = $allGpus | Where-Object { $_.Status -eq "OK" }
        }
        
        if ($candidateGpus) {
            $selectedGpu = $null

            # 1. Prioritize NVIDIA, sort by AdapterRAM to pick the most powerful if multiple
            $selectedGpu = $candidateGpus | Where-Object { $_.AdapterCompatibility -eq "NVIDIA" } | Sort-Object -Property AdapterRAM -Descending | Select-Object -First 1
            
            # 2. If no NVIDIA, prioritize AMD, sort by AdapterRAM
            if (-not $selectedGpu) {
                $selectedGpu = $candidateGpus | Where-Object { $_.AdapterCompatibility -eq "Advanced Micro Devices, Inc." } | Sort-Object -Property AdapterRAM -Descending | Select-Object -First 1
            }

            # 3. If no AMD, prioritize Intel, sort by AdapterRAM
            if (-not $selectedGpu) {
                $selectedGpu = $candidateGpus | Where-Object { $_.AdapterCompatibility -eq "Intel Corporation" } | Sort-Object -Property AdapterRAM -Descending | Select-Object -First 1
            }
            
            # 4. If no specific vendor match, take the one with most RAM from the remaining candidates
            if (-not $selectedGpu) {
                $selectedGpu = $candidateGpus | Sort-Object -Property AdapterRAM -Descending | Select-Object -First 1
            }
            
            if ($selectedGpu) {
                $gpuName = $selectedGpu.Name.Trim()
            }
        } else {
            # If no candidates after filtering (e.g. only problematic ones), try to get the first name from allGpus as a last resort
            $firstAvailable = $allGpus | Select-Object -First 1
            if ($firstAvailable) {
                $gpuName = $firstAvailable.Name.Trim()
            }
        }
    }
    $gpu = $gpuName
    
    # Get terminal info
    $terminal = if ($env:WT_SESSION) { "Windows Terminal" } elseif ($Host.Name -match "ConsoleHost") { "PowerShell Console" } else { $Host.Name }
    
    # Display system information
    Write-Host "$SHIFT_COL$title_color$title$reset"
    Write-Host "$SHIFT_COL$title_color$('-' * $title.Length)$reset"
    Write-Host ""
    Write-Host "$SHIFT_COL$info_color OS${reset}: $os_name"
    Write-Host "$SHIFT_COL$info_color Host${reset}: $hostname"
    Write-Host "$SHIFT_COL$info_color Kernel${reset}: $kernel"
    Write-Host "$SHIFT_COL$info_color Uptime${reset}: $uptime_str"
    Write-Host "$SHIFT_COL$info_color Shell${reset}: $shell_version"
    Write-Host "$SHIFT_COL$info_color Resolution${reset}: $resolution"
    Write-Host "$SHIFT_COL$info_color CPU${reset}: $cpu"
    Write-Host "$SHIFT_COL$info_color GPU${reset}: $gpu"
    Write-Host "$SHIFT_COL$info_color Memory${reset}: $memory_str"
    Write-Host "$SHIFT_COL$info_color Disk${reset}: $disk_str"
    Write-Host "$SHIFT_COL$info_color Terminal${reset}: $terminal"
}

# Function to get weather information (simplified)
function Get-Weather {
    try {
        $weather = Invoke-RestMethod -Uri "http://wttr.in/?format=3" -TimeoutSec 2
        Write-Host "$SHIFT_COL$weather"
    } catch {
        Write-Host "$SHIFT_COL Weather: Not available"
    }
}

# Main function
function Show-PokemonFetch {
    # Enable virtual terminal for ANSI color support
    $Host.UI.RawUI.WindowTitle = "Pokemon Fetch"
    
    # Get and display random Pokémon
    $pokemon = Get-RandomPokemon
    # Randomly decide if the Pokémon is thinking (e.g., 1 in 3 chance)
    $is_thinking_this_time = (Get-Random -Minimum 0 -Maximum 3) -eq 0
    Show-Pokemon -Pokemon $pokemon -IsThinking $is_thinking_this_time
    
    # Display system information
    Get-SystemInfo
    
    # Display weather information
    Get-Weather
    
    # Reset cursor position
    Write-Host "`e[${H}B"
}

# Run the script
Show-PokemonFetch 