# import os
# import re

# def find_vpcf_files(root_dir, output_file):
#     vpcf_pattern = re.compile(rb'".*\.vpcf"')
#     valid_extensions = {'.lua', '.txt', '.cfg'}  # Add other relevant extensions if needed
#     with open(output_file, 'w', encoding='utf-8') as out_file:
#         for subdir, _, files in os.walk(root_dir):
#             for file in files:
#                 if file == 'addon_game_mode.lua':
#                     continue
#                 if not any(file.endswith(ext) for ext in valid_extensions):
#                     continue
#                 file_path = os.path.join(subdir, file)
#                 try:
#                     with open(file_path, 'rb') as f:
#                         while True:
#                             chunk = f.read(1024 * 1024)  # Read in 1MB chunks
#                             if not chunk:
#                                 break
#                             matches = vpcf_pattern.findall(chunk)
#                             for match in matches:
#                                 decoded_match = match.decode('utf-8', errors='ignore')
#                                 out_file.write(f'PrecacheResource("particle", {decoded_match}, context)\n')
#                     print(f"Processed {file_path}")
#                 except Exception as e:
#                     print(f"Error reading {file_path}: {e}")

# # Usage
# find_vpcf_files('.', 'vpcf_resources.txt')

import os
import re

def find_vpcf_files(root_dir, output_file):
    vpcf_pattern = re.compile(rb'"particles/.*\.vpcf"')
    valid_extensions = {'.lua', '.txt', '.cfg'}  # Add other relevant extensions if needed
    with open(output_file, 'w', encoding='utf-8') as out_file:
        for subdir, _, files in os.walk(root_dir):
            for file in files:
                if file == 'addon_game_mode.lua':
                    continue
                if not any(file.endswith(ext) for ext in valid_extensions):
                    continue
                file_path = os.path.join(subdir, file)
                try:
                    with open(file_path, 'rb') as f:
                        while True:
                            chunk = f.read(1024 * 1024)  # Read in 1MB chunks
                            if not chunk:
                                break
                            matches = vpcf_pattern.findall(chunk)
                            for match in matches:
                                decoded_match = match.decode('utf-8', errors='ignore')
                                out_file.write(f'PrecacheResource("particle", {decoded_match}, context)\n')
                    print(f"Processed {file_path}")
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")

# Usage
find_vpcf_files('.', 'vpcf_resources.txt')