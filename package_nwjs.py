import os
import shutil
import urllib.request
import zipfile

# Settings
NWJS_VERSION = "0.69.1"
NWJS_URL = f"https://dl.nwjs.io/v{NWJS_VERSION}/nwjs-v{NWJS_VERSION}-win-ia32.zip"

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BUILD_DIR = os.path.join(BASE_DIR, "build")
NWJS_DIR = os.path.join(BUILD_DIR, "nwjs")
DOWNLOADS_DIR = os.path.join(NWJS_DIR, "downloads")
X86_STAGE = os.path.join(NWJS_DIR, "x86")
X86_ZIP = os.path.join(DOWNLOADS_DIR, f"nwjs-v{NWJS_VERSION}-win-ia32.zip")

def download_file(url, path):
    req = urllib.request.Request(
        url,
        headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'}
    )
    with urllib.request.urlopen(req) as response, open(path, 'wb') as out_file:
        shutil.copyfileobj(response, out_file)

def main():
    # 1. Create directories
    print("Creating packaging directories...")
    os.makedirs(DOWNLOADS_DIR, exist_ok=True)
    os.makedirs(X86_STAGE, exist_ok=True)

    # 2. Download NW.js Windows 32-bit
    if not os.path.exists(X86_ZIP):
        print(f"Downloading NW.js win-ia32 v{NWJS_VERSION}...")
        try:
            download_file(NWJS_URL, X86_ZIP)
            print("Download completed.")
        except Exception as e:
            print(f"Error downloading NW.js: {e}")
            return
    else:
        print("NW.js zip already downloaded.")

    # 3. Extract zip
    extracted_folder_name = f"nwjs-v{NWJS_VERSION}-win-ia32"
    target_extract_path = os.path.join(X86_STAGE, extracted_folder_name)
    if os.path.exists(target_extract_path):
        print("Cleaning previous extraction...")
        shutil.rmtree(target_extract_path)
    
    print("Extracting NW.js...")
    with zipfile.ZipFile(X86_ZIP, 'r') as zip_ref:
        zip_ref.extractall(X86_STAGE)
    print("Extraction completed.")

    # 4. Copy Flutter Web build
    web_build_dir = os.path.join(BUILD_DIR, "web")
    if not os.path.exists(web_build_dir):
        print("Error: Flutter Web build not found. Run 'flutter build web --release --no-web-resources-cdn' first.")
        return

    print("Copying Flutter Web files to NW.js folder...")
    # Copy all items from web_build_dir to target_extract_path
    for item in os.listdir(web_build_dir):
        s = os.path.join(web_build_dir, item)
        d = os.path.join(target_extract_path, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            shutil.copy2(s, d)

    # 5. Fix base href in index.html
    index_html_path = os.path.join(target_extract_path, "index.html")
    if os.path.exists(index_html_path):
        print("Configuring base href in index.html...")
        with open(index_html_path, 'r', encoding='utf-8') as f:
            content = f.read()
        content = content.replace('<base href="/">', '<base href="./">')
        content = content.replace('<base href="$FLUTTER_BASE_HREF">', '<base href="./">')
        with open(index_html_path, 'w', encoding='utf-8') as f:
            f.write(content)

    # 6. Create portable zip package
    archive_name = os.path.join(NWJS_DIR, "AlMohandisPOS-Legacy-Win32")
    print(f"Creating portable ZIP archive: {archive_name}.zip...")
    if os.path.exists(f"{archive_name}.zip"):
        os.remove(f"{archive_name}.zip")
    shutil.make_archive(archive_name, 'zip', X86_STAGE, extracted_folder_name)

    print("\n========================================================")
    print("Packaging Complete!")
    print(f"Portable zip created at: {archive_name}.zip")
    print("Extract this zip on Windows 7 32-bit and double-click 'nw.exe'")
    print("========================================================\n")

if __name__ == "__main__":
    main()
