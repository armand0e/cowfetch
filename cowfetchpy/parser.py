import re
import os

class ParsedCow:
    def __init__(self, name, variables, art_template, comments=None):
        self.name = name
        self.variables = variables
        self.art_template = art_template
        self.comments = comments if comments else []

    def __repr__(self):
        return f"ParsedCow(name='{self.name}', variables={len(self.variables)}, art_lines={len(self.art_template.splitlines())})"

def load_cow_file(file_path):
    """Loads and parses a .cow file."""
    cow_name = os.path.splitext(os.path.basename(file_path))[0]
    variables = {}
    art_lines = []
    comments = []
    in_art_block = False

    # Regex to match variable assignments like $a = "\\e[49m  ";
    # Captures: group(1) = variable name (e.g., 'a')
    #           group(2) = string content (e.g., '\\e[49m  ')
    # This regex handles escaped quotes \\\" inside the string value.
    var_regex = re.compile(r"^\s*\$(\w+)\s*=\s*\"((?:\\\\\"|[^\"])*)\"\s*;(?:\s*#.*)?$")

    with open(file_path, 'r', encoding='utf-8') as f:
        for line_number, line_content in enumerate(f, 1):
            current_line = line_content.rstrip('\n')

            if in_art_block:
                if current_line.strip() == "EOC":
                    in_art_block = False
                    continue
                art_lines.append(current_line)
                continue

            processed_line = current_line.strip()

            if not processed_line: # Skip empty lines
                continue

            if processed_line.startswith("#"):
                comments.append(processed_line)
                continue

            var_match = var_regex.match(current_line)
            if var_match:
                var_name = var_match.group(1)
                # Replace literal '\\e' with actual ESC and '\\"' with '"'.
                var_value = var_match.group(2).replace("\\e", "\x1b").replace("\\\"", "\"")
                variables[var_name] = var_value
                continue
            
            if processed_line.startswith("$the_cow = <<EOC"):
                in_art_block = True
                if processed_line != "$the_cow = <<EOC":
                    print(f"Warning: Content found on same line as $the_cow = <<EOC in {file_path}:{line_number}. Ignoring extra content.")
                continue
            
            if not in_art_block:
                 print(f"Warning: Unrecognized line in {file_path} at line {line_number}: \"{current_line}\"")

    art_template = "\n".join(art_lines)
    return ParsedCow(name=cow_name, variables=variables, art_template=art_template, comments=comments)

if __name__ == '__main__':
    current_file_dir = os.path.dirname(os.path.abspath(__file__))
    falco_cow_path = os.path.join(current_file_dir, "cows", "falco.cow")

    if not os.path.exists(falco_cow_path):
        print(f"Test file not found: {falco_cow_path}")
        # Attempt to find it assuming script is run from project root (e.g. `python cowfetchpy/parser.py`)
        # In this case, current_file_dir is .../cowfetch/cowfetchpy
        # and falco_cow_path would be .../cowfetch/cowfetchpy/cows/falco.cow which is correct.
        # The issue might be if CWD is cowfetchpy, then parser.py is ./parser.py
        # and cows/falco.cow is ./cows/falco.cow.

        # Let's also check relative to CWD if the initial path fails
        # This helps if running `python cowfetchpy/parser.py` from the main `cowfetch` directory.
        # CWD: /c/Users/aranr/OneDrive/Documents/GitHub/cowfetch
        # current_file_dir: /c/Users/aranr/OneDrive/Documents/GitHub/cowfetch/cowfetchpy
        # falco_cow_path (initial): /c/Users/aranr/OneDrive/Documents/GitHub/cowfetch/cowfetchpy/cows/falco.cow
        
        # If the script is at <workspace>/cowfetchpy/parser.py
        # and cows are at <workspace>/cowfetchpy/cows/
        # The path construction `os.path.join(current_file_dir, "cows", "falco.cow")` should be robust.
        
        print(f"Current working directory: {os.getcwd()}")
        print("Please ensure 'falco.cow' is located at 'cowfetchpy/cows/falco.cow'.")

    if os.path.exists(falco_cow_path):
        print(f"Attempting to load: {falco_cow_path}")
        try:
            parsed_falco = load_cow_file(falco_cow_path)
            print(f"Successfully parsed: {parsed_falco.name}")
            print(f"Comments ({len(parsed_falco.comments)}):")
            for c in parsed_falco.comments:
                print(f"  {c}")
            print(f"Variables ({len(parsed_falco.variables)}):\n")
            for k, v in parsed_falco.variables.items():
                # Using repr to make escape sequences like \x1b visible
                print(f"  {k}: {repr(v)}") 
            
            art_sample = "\n".join(parsed_falco.art_template.splitlines()[:5])
            print(f"\nArt Template (first 5 lines):\n{art_sample}")
            print(f"... (total {len(parsed_falco.art_template.splitlines())} lines in art template)")

        except Exception as e:
            print(f"Error parsing {falco_cow_path}: {e}")
            import traceback
            traceback.print_exc()
    else:
        print("Skipping parser test as falco.cow was not found.")
 