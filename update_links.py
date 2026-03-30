import os
import re

base_dir = r"c:\xampp\htdocs\fnff"
count = 0

for root, dirs, files in os.walk(base_dir):
    if ".gemini" in root or "node_modules" in root or "tmp" in root or ".git" in root:
        continue
    for file in files:
        if file == "index.html":
            file_path = os.path.join(root, file)
            
            rel_path = os.path.relpath(root, base_dir)
            if rel_path == ".":
                depth = 0
            else:
                depth = len(rel_path.split(os.sep))
                
            # skip the donate-us actual file
            if rel_path == "donate-us":
                continue
                
            if depth == 0:
                donate_rel = "donate-us/"
            else:
                donate_rel = "../" * depth + "donate-us/"
                
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace wa.link links containing Donate Now
                new_content = re.sub(
                    r'<a href="https://wa\.link/[^"]*"([^>]*)>([\s\S]*?Donate Now[\s\S]*?)</a>',
                    rf'<a href="{donate_rel}"\1>\2</a>',
                    content,
                    flags=re.IGNORECASE
                )
                
                new_content = re.sub(
                    r'<a href="(?:(?:\.\./)*)?contact(?:/)?"([^>]*)>([\s\S]*?Donate Now[\s\S]*?)</a>',
                    rf'<a href="{donate_rel}"\1>\2</a>',
                    new_content,
                    flags=re.IGNORECASE
                )
                
                if content != new_content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated: {rel_path}")
                    count += 1
            except Exception as e:
                print(f"Error reading {file_path}: {e}")

print(f"Total files updated: {count}")
