# Placeholder for display logic 

import colorama
import re
from .parser import ParsedCow # Assuming parser.py is in the same directory

def render_cow(parsed_cow: ParsedCow, message: str = ""):
    """Renders the parsed cow with the given message and prints it."""
    colorama.init(autoreset=True)

    # Prepare variables for substitution
    # Start with a copy of the cow's own variables
    substitutions = parsed_cow.variables.copy()

    # Handle the $thoughts / $t variable based on the message
    # The falco.cow example has: $t = "$thoughts ";
    # So we need to define $thoughts and then $t will pick it up.
    # If $t is directly used and not via $thoughts in other cow files, this might need adjustment.
    
    # For now, let's assume the message directly populates '$thoughts'
    # and that '$t' in the art template will be replaced by the value of '$thoughts' from the variables.
    # If $t itself is defined as "$thoughts ", then replacing $thoughts in the dictionary is key.
    if "t" in substitutions and "$thoughts" in substitutions["t"]:
        substitutions["thoughts"] = message
    else:
        # If $t isn't defined via $thoughts, or if $thoughts isn't in its definition,
        # we can try to set $t directly if it exists, or $thoughts if it exists.
        # This might need to be more robust based on various .cow file conventions.
        # For falco.cow, $t is "$thoughts ", so setting substitutions["thoughts"] is correct.
        # If a cow file just uses $t for the message, then this would be: substitutions['t'] = message
        # Let's check the falco.cow structure: $t = "$thoughts " - so $thoughts needs to be set.
        substitutions["thoughts"] = message # Defaulting to this, as per falco.cow

    # Perform substitutions in the art template
    # A simple loop of string.replace might be problematic if variable names are substrings of others
    # (e.g., $a and $ax). Using regex substitution is safer for specific $variable patterns.
    # The pattern \$\w+ will match $ followed by one or more word characters.
    # We need to ensure we only replace defined variables.

    rendered_art = parsed_cow.art_template
    
    # Substitute $thoughts first if it's a variable used to define $t or others
    if 'thoughts' in substitutions:
        rendered_art = rendered_art.replace("$thoughts", substitutions['thoughts'])

    # Substitute all other variables like $a, $b, $x, and $t itself.
    # Sort by length descending to replace longer matches first (e.g. $long_var before $long)
    # Although with $ prefix, direct match should be fine.
    for var_name, var_value in sorted(substitutions.items(), key=lambda item: len(item[0]), reverse=True):
        # Ensure we replace the placeholder $var_name, not just var_name
        placeholder = f"${var_name}"
        rendered_art = rendered_art.replace(placeholder, var_value)

    print(rendered_art)
    colorama.deinit() # Clean up colorama

if __name__ == '__main__':
    # This test requires parser.py and a sample cow file.
    # It's a bit more involved to run directly due to relative imports and file paths.
    import os
    from .parser import load_cow_file

    print("Running display.py test...")
    # Assuming display.py is in cowfetchpy/ and falco.cow is in cowfetchpy/cows/
    current_dir = os.path.dirname(os.path.abspath(__file__))
    falco_path = os.path.join(current_dir, "cows", "falco.cow")

    if not os.path.exists(falco_path):
        print(f"Test cow file not found: {falco_path}")
        print("Please ensure cowfetchpy/cows/falco.cow exists.")
    else:
        print(f"Loading test cow: {falco_path}")
        try:
            test_cow = load_cow_file(falco_path)
            print("Cow loaded. Rendering with a test message...")
            render_cow(test_cow, message="This is a test message!")
            print("\nRendering again with a different message (Falco thinking)...")
            # The falco.cow only has $t = "$thoughts ". It doesn't have specific think/say characters like o / O
            # The original PowerShell script added those *outside* the cow definition.
            # We can emulate this in the message string itself if desired, or add logic to wrap the message.
            render_cow(test_cow, message="oO(Hmm... thinking...)Oo")
            print("\nRendering with no message...")
            render_cow(test_cow)

        except ImportError as ie:
            print(f"ImportError: {ie}. Make sure parser.py is accessible.")
            print("Try running as a module: python -m cowfetchpy.display")
        except FileNotFoundError as fe:
            print(f"FileNotFoundError: {fe}. Check cow file path.")
        except Exception as e:
            print(f"An error occurred during the display test: {e}")
            import traceback
            traceback.print_exc() 