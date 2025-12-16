
import sys

file_path = r"C:\Users\josha\.local\bin\ubs"
try:
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if "resolve_git_metadata(){" in line or "resolve_git_metadata() {" in line:
                print(f"Definition found at line {i+1}")
                # Print the function body (heuristic: print next 50 lines)
                for j in range(i, min(i+50, len(lines))):
                    print(f"{j+1}: {lines[j].rstrip()}")
                break
except Exception as e:
    print(f"Error: {e}")
