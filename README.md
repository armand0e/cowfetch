# PokemonFetch for Windows PowerShell

A Windows PowerShell port of the [pokemonfetch](https://github.com/Urinx/pokemonfetch) system information tool. This version displays a random Pokémon ASCII art alongside system information when you start PowerShell.

## Features

- Displays a random Pokémon ASCII art on startup
- Shows system information similar to neofetch
- Shows current weather information
- Automatically runs when you start PowerShell

## Requirements

- Windows PowerShell 5.1+ or PowerShell Core 6.0+
- Terminal that supports ANSI escape sequences (Windows Terminal recommended)
- CaskaydiaCove Nerd Font for proper glyph rendering ([download link](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip))

## Installation

1. Clone this repository:
   ```powershell
   git clone https://github.com/YourUsername/pokemonfetch-windows.git
   cd pokemonfetch-windows
   ```

2. Run the setup script to add pokemonfetch to your PowerShell profile:
   ```powershell
   .\profile-setup.ps1
   ```

3. Restart PowerShell to see pokemonfetch in action!

## Manual Installation

If you prefer to set it up manually:

1. Clone this repository to a permanent location on your system
2. Open your PowerShell profile (run `notepad $PROFILE.CurrentUserAllHosts`)
3. Add the following line (update the path to point to where you cloned the repo):
   ```powershell
   & 'C:\path\to\pokemonfetch-windows\pokemonfetch.ps1'
   ```
4. Save the file and restart PowerShell

## Customization

You can modify the `pokemonfetch.ps1` script to customize:

- Which system information is displayed
- The colors used for the display
- The positioning of elements

**Adding Custom Pokémon Art:**

- You can add your own `.cow` files (ANSI art) to the `cows` directory located within your installation folder (e.g., `$env:USERPROFILE\pokemonfetch-windows\cows`). The script will randomly pick from any `.cow` file in this directory.

**Think/Say Bubbles:**

- The Pokémon's name is displayed below its art. This name will randomly appear in either a "say" style bubble `( Name )` or a "think" style bubble `o ( Name ) O`.

## Credits

- Original [pokemonfetch](https://github.com/Urinx/pokemonfetch) by [Urinx](https://github.com/Urinx)
- ASCII art from [pokemonsay](https://github.com/possatti/pokemonsay)
- Based on the functionality of [neofetch](https://github.com/dylanaraps/neofetch)