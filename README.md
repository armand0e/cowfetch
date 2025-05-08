# cowfetchpy

A Python version of a "cowfetch" or "pokemonfetch" like tool, displaying colorful ASCII/ANSI art cows (and other creatures, eventually!) in your terminal. It uses a specific `.cow` file format that includes inline color definitions.

This project is a refactor of an earlier PowerShell-based version and aims to be a cross-platform Python package.

(The original screenshot.png might not fully represent the current Python version's output, especially regarding system info, which is not yet implemented in this version.)

## Features (Current)

*   Displays a creature from a `.cow` file.
*   Parses `.cow` files with inline ANSI color definitions.
*   Select a specific creature or a random one (currently, only "falco" is available).
*   Display a message with the creature.
*   List available creatures.
*   Cross-platform (thanks to Python and Colorama).

## Requirements

*   Python 3.8+
*   A terminal that supports ANSI escape sequences (most modern terminals do).

## Installation

You will need Python 3.8+ and `pip`. You can also use `uv` (from [astral.sh/uv](https://astral.sh/uv)) as a faster alternative to `pip`.

**From source (e.g., after cloning this repository):**

1.  Clone the repository:
    ```bash
    git clone https://github.com/aranrhunt/cowfetch.git # Or your fork
    cd cowfetch
    ```

2.  Create and activate a virtual environment (recommended):
    *   Using `venv` (standard Python):
        ```bash
        python -m venv .venv
        source .venv/bin/activate  # On Linux/macOS
        # .venv\Scripts\activate    # On Windows
        ```
    *   Using `uv`:
        ```bash
        uv venv
        source .venv/bin/activate  # On Linux/macOS
        # .venv\Scripts\activate    # On Windows
        ```

3.  Install `cowfetchpy` in editable mode:
    *   Using `pip`:
        ```bash
        pip install -e .
        ```
    *   Using `uv`:
        ```bash
        uv pip install -e .
        ```

**(Once published to PyPI, installation would be simpler, e.g., `pip install cowfetchpy` or `uv pip install cowfetchpy`)**

## Usage

After installation, the `cowfetchpy` command will be available.

*   **Show a random creature (currently defaults to falco):**
    ```bash
    cowfetchpy
    ```

*   **Show a specific creature:**
    ```bash
    cowfetchpy falco
    ```

*   **Show a creature with a message:**
    ```bash
    cowfetchpy falco "Hello there!"
    ```
    Or for a random creature:
    ```bash
    cowfetchpy "Just a random message."
    ```

*   **List available creatures:**
    ```bash
    cowfetchpy --list-cows
    ```

## Adding More Creatures

This package uses a specific `.cow` file format where colors and the art template are defined within the file itself. Example: `cowfetchpy/cows/falco.cow`.

To add more creatures:
1.  Create a new `.cow` file in the `cowfetchpy/cows/` directory.
2.  Follow the format of `falco.cow`:
    *   Define color variables (e.g., `$a = "\e[48;5;234m  ";`).
    *   Define `$x = "\e[49m  ";` for resetting colors.
    *   Define `$t = "$thoughts ";` (or similar) if you want the message to be part of `$t`.
    *   The main art block should be defined with `$the_cow = <<EOC ... EOC`.
    *   Use your color variables (e.g., `$a`, `$b`) and `$t` within the `EOC` block.
3.  The new creature should then be available via `cowfetchpy --list-cows` and can be displayed by its filename (without the `.cow` extension).

**Note:** Currently, only the `falco.cow` file is provided in the correct format. Many creature files from the original project exist in the `old/cows/` directory but require conversion to this new format to be usable by `cowfetchpy`.

## Future Enhancements (Potential)

*   Conversion script for old `.cow` files.
*   System information display (similar to neofetch/pokemonfetch).
*   More configuration options.

## Development

(Details about setting up for development, running tests, etc., can be added here.)

To make the package installable, ensure `setuptools` can find your data files.
If your `pyproject.toml` is set up for `setuptools` and you are using `include_package_data = true` (or relying on modern `setuptools` auto-detection for files versioned in Git within the package), your `cowfetchpy/cows/` directory should be included.

For explicit control with `setuptools`, you might add a `MANIFEST.in` file in your project root with:
```
recursive-include cowfetchpy/cows *.cow
```
And in `pyproject.toml` ensure `[tool.setuptools]` has `include_package_data = true` if it's not already standard.
However, often for files within the package, `setuptools` with Git integration handles this well.

## License

This project is licensed under the terms of the [LICENSE](./LICENSE) file.