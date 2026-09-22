import os
import shutil
import urllib.request
import zipfile

# Settings
NWJS_VERSION = "0.69.1"
NWJS_URL = f"https://dl.nwjs.io/v{NWJS_VERSION}/nwjs-v{NWJS_VERSION}-win-ia32.zip"

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
BUILD_DIR = os.path.join(BASE_DIR, "mobile", "build")
NWJS_DIR = os.path.join(BASE_DIR, "build", "nwjs")
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
    print("Creating packaging directories...")
    os.makedirs(DOWNLOADS_DIR, exist_ok=True)
    os.makedirs(X86_STAGE, exist_ok=True)

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

    extracted_folder_name = f"nwjs-v{NWJS_VERSION}-win-ia32"
    target_extract_path = os.path.join(X86_STAGE, extracted_folder_name)
    if os.path.exists(target_extract_path):
        print("Cleaning previous extraction...")
        shutil.rmtree(target_extract_path)
    
    print("Extracting NW.js...")
    with zipfile.ZipFile(X86_ZIP, 'r') as zip_ref:
        zip_ref.extractall(X86_STAGE)
    print("Extraction completed.")

    web_build_dir = os.path.join(BUILD_DIR, "web")
    if not os.path.exists(web_build_dir):
        print("Error: Flutter Web build not found.")
        return

    print("Copying Flutter Web files to NW.js folder...")
    for item in os.listdir(web_build_dir):
        s = os.path.join(web_build_dir, item)
        d = os.path.join(target_extract_path, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            shutil.copy2(s, d)

    # Ensure package.json is copied from mobile/web/package.json
    package_json_src = os.path.join(BASE_DIR, "mobile", "web", "package.json")
    if os.path.exists(package_json_src):
        shutil.copy2(package_json_src, os.path.join(target_extract_path, "package.json"))

    # Rename nw.exe to AlMohandisPOS.exe for a professional appearance
    orig_exe = os.path.join(target_extract_path, "nw.exe")
    app_exe = os.path.join(target_extract_path, "AlMohandisPOS.exe")
    if os.path.exists(orig_exe):
        if os.path.exists(app_exe):
            os.remove(app_exe)
        os.rename(orig_exe, app_exe)
        print("Renamed nw.exe -> AlMohandisPOS.exe")

    # Create convenient launcher batch file
    bat_path = os.path.join(target_extract_path, "Start-AlMohandis-POS.bat")
    with open(bat_path, "w") as f:
        f.write("@echo off\r\nstart \"\" \"%~dp0AlMohandisPOS.exe\"\r\n")

    # Copy icons
    icon_src = os.path.join(BASE_DIR, "mobile", "windows", "runner", "resources", "app_icon.ico")
    if os.path.exists(icon_src):
        shutil.copy2(icon_src, os.path.join(target_extract_path, "app_icon.ico"))

    png_src = os.path.join(BASE_DIR, "mobile", "assets", "images", "app_icon.png")
    if os.path.exists(png_src):
        shutil.copy2(png_src, os.path.join(target_extract_path, "favicon.png"))

    index_html_path = os.path.join(target_extract_path, "index.html")
    if os.path.exists(index_html_path):
        print("Configuring base href in index.html...")
        with open(index_html_path, 'r', encoding='utf-8') as f:
            c = f.read()
        c = c.replace('<base href="/">', '<base href="./">')
        c = c.replace('<base href="">', '<base href="./">')
        with open(index_html_path, 'w', encoding='utf-8') as f:
            f.write(c)

    archive_name = os.path.join(BASE_DIR, "AlMohandisPOS-Windows-32bit-64bit")
    print(f"Creating portable ZIP archive: {archive_name}.zip...")
    if os.path.exists(f"{archive_name}.zip"):
        os.remove(f"{archive_name}.zip")
    shutil.make_archive(archive_name, 'zip', X86_STAGE, extracted_folder_name)

    print("\n========================================================")
    print("Packaging Complete!")
    print(f"Portable zip created at: {archive_name}.zip")
    print("Supports Windows 7, 8, 8.1, 10, 11 (32-bit & 64-bit)")
    print("========================================================\n")

if __name__ == '__main__':
    main()
