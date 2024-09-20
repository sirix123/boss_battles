import re
import os

def parse_ability_special(ability_special_text):
    """
    Parse the 'AbilitySpecial' section from the old format.
    """
    # Improved regex pattern to match special blocks more effectively
    special_pattern = re.compile(r'"(\d+)"\s*\{\s*([^}]+?)\s*\}', re.DOTALL)
    specials = []

    # Find all special entries
    for match in special_pattern.finditer(ability_special_text):
        block = match.group(2)
        special_block = {}
        for line in block.splitlines():
            line = line.strip()
            if line:
                # Remove comments and extract key-value pairs
                line = re.sub(r'//.*', '', line).strip()
                parts = re.findall(r'"(.*?)"\s+"([^"]+)"', line)
                for key, value in parts:
                    if key != "var_type":  # Ignore var_type
                        special_block[key] = value
        if special_block:
            specials.append(special_block)

        print(f"AbilitySpecial Text:\n{ability_special_text}")
        print(f"Parsed Specials: {specials}")
    
    return specials


def convert_to_ability_values(specials):
    """
    Convert parsed specials into the new 'AbilityValues' format.
    """
    ability_values = {}

    for special in specials:
        for key, value in special.items():
            ability_values[key] = value

    return ability_values

def format_ability_values(ability_values):
    """
    Format the 'AbilityValues' dictionary into the desired KV format with proper indentation.
    The entire block inside "AbilityValues" is indented by 8 spaces.
    """
    if not ability_values:
        return '"AbilityValues"\n        {\n        }'

    formatted_text = '"AbilityValues"\n        {\n'
    for key, value in ability_values.items():
        formatted_text += f'            "{key}" "{value}"\n'
    formatted_text += '        }'
    return formatted_text

def convert_ability_special_to_new_format(ability_special_text):
    """
    Convert old 'AbilitySpecial' to new 'AbilityValues'.
    """
    specials = parse_ability_special(ability_special_text)
    new_ability_values = convert_to_ability_values(specials)

    return format_ability_values(new_ability_values)

def process_file(input_filename, output_filename):
    with open(input_filename, 'r', encoding='utf-8') as file:
        content = file.read()

    # Find and replace all AbilitySpecial blocks
    ability_special_pattern = re.compile(r'"AbilitySpecial"\s*{(?:[^{}]*|{(?:[^{}]*|{[^{}]*})*})*}', re.DOTALL)
    
    def replace_ability_special(match):
        ability_special_text = match.group(0)
        new_ability_values = convert_ability_special_to_new_format(ability_special_text)
        return new_ability_values

    # Replace all occurrences of AbilitySpecial with AbilityValues
    new_content = ability_special_pattern.sub(replace_ability_special, content)

    # Write the modified content to the output file
    os.makedirs(os.path.dirname(output_filename), exist_ok=True)
    with open(output_filename, 'w', encoding='utf-8') as file:
        file.write(new_content)

    print(f"Processed {input_filename} and saved results to {output_filename}")


def process_all_files_in_folder():
    # Get the directory of the script
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Create an 'output' folder if it doesn't exist
    output_dir = os.path.join(script_dir, 'output')
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Process all .txt files in the script's directory and subdirectories
    for root, dirs, files in os.walk(script_dir):
        # Exclude the output directory
        if 'output' in dirs:
            dirs.remove('output')
        
        for filename in files:
            if filename.endswith('.txt'):
                input_path = os.path.join(root, filename)
                # Create a relative path for the output file
                rel_path = os.path.relpath(root, script_dir)
                output_path = os.path.join(output_dir, rel_path, filename)
                process_file(input_path, output_path)


# Run the script to process all .txt files in the same folder and subfolders
if __name__ == "__main__":
    process_all_files_in_folder()
