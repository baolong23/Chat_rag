import os
import sys
import zipfile

def zip_directory(source_dir, zip_path):
    source_dir = os.path.abspath(source_dir)
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(source_dir):
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, start=source_dir)
                zipf.write(abs_path, arcname=rel_path)
    print(f"[✓] Zipped '{source_dir}' → '{zip_path}'")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python zip_folder.py <source_folder> <output_zip_file>")
        sys.exit(1)

    source_folder = sys.argv[1]
    output_zip = sys.argv[2]
    zip_directory(source_folder, output_zip)