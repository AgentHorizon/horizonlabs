import os

# Identify paths relative to this script's location
script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.abspath(os.path.join(script_dir, "../../"))
README_FILE = os.path.join(repo_root, 'README.md')

# Folders to scan for scripts
CATEGORIES = ['BASH', 'Python', 'Nodejs', 'PHP']

def generate_table():
    lines = ["| Category | Script Name | Link |\n", "| :--- | :--- | :--- |\n"]
    found_any = False
    
    for cat in CATEGORIES:
        cat_path = os.path.join(repo_root, cat)
        if os.path.exists(cat_path):
            # List files, ignoring hidden ones (like .DS_Store)
            files = [f for f in os.listdir(cat_path) if os.path.isfile(os.path.join(cat_path, f)) and not f.startswith('.')]
            for file in files:
                lines.append(f"| {cat} | {file} | [View](./{cat}/{file}) |\n")
                found_any = True
    
    return "".join(lines) if found_any else "| No scripts found yet | | |\n"

def update_readme(content):
    if not os.path.exists(README_FILE):
        print("Error: README.md not found in root.")
        return

    with open(README_FILE, 'r') as f:
        data = f.read()

    start_marker = ""
    end_marker = ""
    
    if start_marker not in data or end_marker not in data:
        print("Error: Markers not found in README.md")
        return

    start_idx = data.find(start_marker) + len(start_marker)
    end_idx = data.find(end_marker)
    
    new_readme = data[:start_idx] + "\n\n" + content + "\n" + data[end_idx:]
    
    with open(README_FILE, 'w') as f:
        f.write(new_readme)

if __name__ == "__main__":
    table_content = generate_table()
    update_readme(table_content)
    print("README.md updated successfully.")
