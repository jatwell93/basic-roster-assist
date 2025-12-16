
import sys
import os

file_path = r"C:\Users\josha\.local\bin\ubs"

try:
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    new_lines = []
    in_function = False
    modified = False

    for line in lines:
        if "resolve_git_metadata(){" in line or "resolve_git_metadata() {" in line:
            in_function = True
        
        if in_function:
            if line.strip() == "return":
                # This matches the return inside the if block
                new_lines.append(line.replace("return", "return 0"))
                modified = True
                continue
            if "[[ -n \"$remote\" && -n \"$commit\" ]] || return" in line:
                # This matches the return after remote check
                new_lines.append(line.replace("return", "return 0"))
                modified = True
                continue
            if line.strip() == "}":
                in_function = False
        
        new_lines.append(line)

    if modified:
        with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
            f.writelines(new_lines)
        print("Successfully patched ubs script.")
    else:
        print("No changes made. Patterns not found.")

except Exception as e:
    print(f"Error: {e}")
