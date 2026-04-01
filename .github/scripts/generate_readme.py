import os

# Setup paths relative to the script location
script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(script_dir, "../../"))
README_FILE = os.path.join(repo_root, 'README.md')
CATEGORIES = ['BASH', 'Python', 'Nodejs', 'PHP']

def generate_table():
    """Scans directories and creates the Markdown table string."""
    lines = ["| Category | Script Name | Link |\n", "| :--- | :--- | :--- |\n"]
    found_any = False
    
    for cat in CATEGORIES:
        cat_path = os.path.join(repo_root, cat)
        if os.path.exists(cat_path):
            # List files, excluding hidden ones (like .DS_Store)
            files = sorted([f for f in os.listdir(cat_path) 
                            if os.path.isfile(os.path.join(cat_path, f)) 
                            and not f.startswith('.')])
            for file in files:
                lines.append(f"| {cat} | {file} | [View](./{cat}/{file}) |\n")
                found_any = True
                
    return "".join(lines) if found_any else "| No scripts found | | |\n"

def update_readme(table_content):
    """Reads README, finds markers using fuzzy matching, and injects the table."""
    if not os.path.exists(README_FILE):
        print(f"Error: {README_FILE} not found.")
        return

    with open(README_FILE, 'r') as f:
        lines = f.readlines()

    new_content = []
    inside_metadata = False
    found_start = False
    found_end = False

    for line in lines:
        # Use 'in' for fuzzy matching to ignore hidden spaces/brackets
        if "START_METADATA" in line:
            new_content.append(line)  # Keep the marker
            new_content.append(table_content + "\n") # Inject the new table
            inside_metadata = True
            found_start = True
            continue
        
        if "END_METADATA" in line:
            inside_metadata = False
            new_content.append(line)  # Keep the marker
            found_end = True
            continue
        
        # Only keep lines that are NOT between the markers
        if not inside_metadata:
            new_content.append(line)

    if found_start and found_end:
        with open(README_FILE, 'w') as f:
            f.writelines(new_content)
        print("✅ Success: README.md updated successfully!")
    else:
        print("❌ Error: Could not find both markers in README.md.")
        print(f"DEBUG: Found Start: {found_start} | Found End: {found_end}")

if __name__ == "__main__":
    table = generate_table()
    update_readme(table)