import os
import re

dir_path = "c:/Users/Sandeep Kumar/OneDrive/Pictures/Documents/OneDrive/Pictures/Documents/Main Project Code/cocobot/lib"

def process_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)

    if new_content != content:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Fixed withOpacity in {file_path}")

for root, dirs, files in os.walk(dir_path):
    for name in files:
        if name.endswith(".dart"):
            process_file(os.path.join(root, name))
