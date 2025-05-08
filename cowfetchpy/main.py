# Placeholder for CLI and main entry point 

import argparse
import random
import sys
from importlib import resources

from .parser import load_cow_file, ParsedCow
from .display import render_cow

# Module-level reference to the cows sub-package
COWS_PACKAGE = "cowfetchpy.cows"

def get_cow_names():
    """Returns a list of available .cow file names (without .cow extension)."""
    cow_file_names = []
    try:
        for item in resources.contents(COWS_PACKAGE):
            if item.endswith(".cow") and resources.is_resource(COWS_PACKAGE, item):
                cow_file_names.append(item[:-4]) # Remove .cow extension
    except FileNotFoundError: # ModuleNotFoundError can also occur if package structure is wrong
        # This might happen if the cows directory is missing or the package isn't installed correctly
        print(f"Error: Cow directory '{COWS_PACKAGE}' not found or is empty.", file=sys.stderr)
        return []
    return sorted(cow_file_names)

def get_cow_file_path(cow_name: str):
    """Returns a Path-like object for a given cow name. Exits if not found."""
    actual_file_name = f"{cow_name}.cow"
    try:
        if not resources.is_resource(COWS_PACKAGE, actual_file_name):
            print(f"Error: Cow '{cow_name}' not found in '{COWS_PACKAGE}'.", file=sys.stderr)
            print(f"Ensure '{actual_file_name}' exists within the package.", file=sys.stderr)
            sys.exit(1)
        
        # importlib.resources.path returns a context manager
        return resources.path(COWS_PACKAGE, actual_file_name)
    except FileNotFoundError:
        print(f"Error: Cow file '{actual_file_name}' for cow '{cow_name}' could not be accessed in '{COWS_PACKAGE}'.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred while accessing cow '{cow_name}': {e}", file=sys.stderr)
        sys.exit(1)

def cli():
    parser = argparse.ArgumentParser(
        description="Display a colorful ASCII/ANSI art cow (or other creature) in your terminal.",
        formatter_class=argparse.RawTextHelpFormatter
    )

    parser.add_argument(
        "cow_name",
        nargs="?",
        default=None,
        help="Name of the cow to display (e.g., falco). If not provided, a random cow is chosen."
    )
    parser.add_argument(
        "message",
        nargs="*",
        help="Message for the cow to say. If multiple words, they will be joined."
    )
    parser.add_argument(
        "-l", "--list-cows",
        action="store_true",
        help="List all available cow names and exit."
    )
    # Add verbosity or other options here later if needed

    args = parser.parse_args()

    available_cows = get_cow_names()

    if not available_cows and not args.list_cows:
        # get_cow_names would have printed an error, but we should exit if no cows for display
        sys.exit(1)

    if args.list_cows:
        if available_cows:
            print("Available cows:")
            for name in available_cows:
                print(f"  {name}")
        else:
            print("No cows found.")
        sys.exit(0)

    target_cow_name = args.cow_name
    if not target_cow_name:
        if not available_cows:
            print("Error: No cows available to choose from randomly.", file=sys.stderr)
            sys.exit(1)
        target_cow_name = random.choice(available_cows)
        print(f"No cow specified, choosing a random one: {target_cow_name}", file=sys.stderr)
    elif target_cow_name not in available_cows:
        print(f"Error: Cow '{target_cow_name}' is not in the list of available cows.", file=sys.stderr)
        print("Use --list-cows to see the available names.", file=sys.stderr)
        sys.exit(1)

    message_str = " ".join(args.message) if args.message else ""

    try:
        with get_cow_file_path(target_cow_name) as cow_file:
            parsed_cow = load_cow_file(str(cow_file)) # load_cow_file expects a string path
            render_cow(parsed_cow, message=message_str)
    except FileNotFoundError:
        # This specific error might be redundant if get_cow_file_path exits, but good for safety
        print(f"Error: Could not load cow file for '{target_cow_name}'. File not found.", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc() # For debugging
        sys.exit(1)

if __name__ == "__main__":
    # This allows running `python -m cowfetchpy.main` or `python cowfetchpy/main.py` (if path is set up)
    cli() 