import os

# Identify paths relative to this script's location
# This allows the script to run from any directory
script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(script_dir, "../../"))
README_FILE = os.path.join(repo_root, 'README.md')

# Folders to scan for scripts (Case-sensitive)
CATEGORIES = ['BASH', 'Python', 'Nodejs', 'PHP']

def generate_table():
    """Scans category folders and builds a Markdown table string."""
    lines = ["| Category | Script Name | Link |\n", "| :--- | :--- | :--- |\n"]
    found_any = False
    
    for cat in CATEGORIES:
        cat_path = os.path.join(repo_root, cat)
        if os.path.exists(cat_path):
            # List files, ignoring hidden system files (like .DS_Store)
            files = sorted([f for f in os.listdir(cat_path) 
                     if os.path.isfile(os.path.join(cat_path, f)) 
                     and not f.startswith('.')])
            
            for file in files:
                lines.append(f"| {cat} | {file} | [View](./{cat}/{file}) |\n")
                found_any = True
    
    return "".join(lines) if found_any else "| No scripts found yet | | |\n"

def update_readme(content):
    """Updates the README.md file specifically between the metadata markers."""
    if not os.path.exists(README_FILE):
        print(f"Error: {README_FILE} not found.")
        return

    with open(README_FILE, 'r') as f:
        original_lines = f.readlines()

    start_marker = ""
    end_marker = ""
    
    new_file_content = []
    inside_metadata = False
    found_start = False
    found_end = False

    for line in original_lines:
        # Detect the start marker
        if start_marker in line:
            new_file_content.append(line)
            # Inject the new table content here
            new_file_content.append("\n" + content + "\n")
            inside_metadata = True
            found_start = True
            continue
        
        # Detect the end marker
        if end_marker in line:
            inside_metadata = False
            new_file_content.append(line)
            found_end = True
            continue
        
        # If we are between markers, skip the old lines
        if not inside_metadata:
            new_file_content.append(line)

    if not found_start or not found_end:
        print("Error: Could not find both markers in README.md.")
        print("Ensure and exist.")
        return

    with open(README_FILE, 'w') as f:
        f.writelines(new_file_content)
    print("README.md updated successfully.")

if __name__ == "__main__":
    table_content = generate_table()
    update_readme(table_content)
