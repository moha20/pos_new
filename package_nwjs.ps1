# package_nwjs.ps1
# Automates packaging the Flutter Web app into a Windows 32-bit (x86) and 64-bit (x64) desktop installer using NW.js.
# Supports Windows 7, 8, 10, 11.

$ErrorActionPreference = "Stop"

# Version 0.69.1 is the last version supporting Windows 7/8.
$NWJS_VERSION = "0.69.1"
$NWJS_X86_URL = "https://dl.nwjs.io/v0.69.1/nwjs-v0.69.1-win-ia32.zip"
$NWJS_X64_URL = "https://dl.nwjs.io/v0.69.1/nwjs-v0.69.1-win-x64.zip"

$BASE_DIR = Resolve-Path .
$BUILD_DIR = Join-Path $BASE_DIR "build"
$NWJS_DIR = Join-Path $BUILD_DIR "nwjs"
$DOWNLOADS_DIR = Join-Path $NWJS_DIR "downloads"
$X86_STAGE = Join-Path $NWJS_DIR "x86"
$X64_STAGE = Join-Path $NWJS_DIR "x64"

$X86_ZIP = Join-Path $DOWNLOADS_DIR "nwjs-v$NWJS_VERSION-win-ia32.zip"
$X64_ZIP = Join-Path $DOWNLOADS_DIR "nwjs-v$NWJS_VERSION-win-x64.zip"

# Create required directories
Write-Host "Creating NW.js packaging directories..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $DOWNLOADS_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $X86_STAGE | Out-Null
New-Item -ItemType Directory -Force -Path $X64_STAGE | Out-Null

# --- Helper function to download file with curl.exe ---
function Download-FileWithCurl {
    param(
        [string]$Url,
        [string]$Path
    )
    if (Test-Path $Path) {
        $file = Get-Item $Path
        if ($file.Length -gt 10MB) {
            Write-Host "File already exists and looks valid: $Path" -ForegroundColor Green
            return
        }
        # Delete invalid/partial download
        Remove-Item $Path -Force
    }
    Write-Host "Downloading $Url to $Path using curl.exe..." -ForegroundColor Yellow
    # Call native curl.exe
    & curl.exe -L -o "$Path" "$Url"
}

# --- Download NW.js binaries ---
try {
    Download-FileWithCurl -Url $NWJS_X86_URL -Path $X86_ZIP
    Download-FileWithCurl -Url $NWJS_X64_URL -Path $X64_ZIP
} catch {
    Write-Error "Failed to download NW.js binaries. Please check your internet connection: $_"
}

# --- Extract NW.js ---
function Extract-ArchiveSafe {
    param(
        [string]$ZipPath,
        [string]$DestinationPath
    )
    Write-Host "Extracting $ZipPath to $DestinationPath..." -ForegroundColor Yellow
    # Clean destination first
    if (Test-Path $DestinationPath) {
        Remove-Item -Path $DestinationPath -Recurse -Force | Out-Null
    }
    New-Item -ItemType Directory -Force -Path $DestinationPath | Out-Null
    
    Expand-Archive -Path $ZipPath -DestinationPath $DestinationPath -Force
}

Extract-ArchiveSafe -ZipPath $X86_ZIP -DestinationPath $X86_STAGE
Extract-ArchiveSafe -ZipPath $X64_ZIP -DestinationPath $X64_STAGE

# --- Copy Flutter Web Build and configure base href ---
$WEB_BUILD = Join-Path $BUILD_DIR "web"
if (-not (Test-Path $WEB_BUILD)) {
    Write-Error "Flutter Web build not found at $WEB_BUILD. Run 'flutter build web --release' first."
}

function Prep-NWJS-Folder {
    param(
        [string]$StagePath,
        [string]$SubfolderName
    )
    $AppPath = Join-Path $StagePath $SubfolderName
    Write-Host "Copying Flutter Web build to $AppPath..." -ForegroundColor Yellow
    
    # Copy web assets
    Copy-Item -Path "$WEB_BUILD\*" -Destination $AppPath -Recurse -Force
    
    # Fix base href in index.html for NW.js local execution
    $IndexHtml = Join-Path $AppPath "index.html"
    if (Test-Path $IndexHtml) {
        Write-Host "Configuring base href in $IndexHtml..." -ForegroundColor Yellow
        $content = Get-Content $IndexHtml
        $content = $content -replace '<base href="/">', '<base href="./">'
        $content | Set-Content $IndexHtml -Force
    }
}

Prep-NWJS-Folder -StagePath $X86_STAGE -SubfolderName "nwjs-v$NWJS_VERSION-win-ia32"
Prep-NWJS-Folder -StagePath $X64_STAGE -SubfolderName "nwjs-v$NWJS_VERSION-win-x64"

# --- Generate Inno Setup ISS scripts ---
$ISCC_PATH = "C:\Users\salah\AppData\Local\Programs\Inno Setup 6\ISCC.exe"
if (-not (Test-Path $ISCC_PATH)) {
    # Try Program Files alternative
    $ISCC_PATH = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
}

if (-not (Test-Path $ISCC_PATH)) {
    Write-Host "Inno Setup compiler (ISCC.exe) not found. Skipping installer generation. You can find the raw folders under build/nwjs/." -ForegroundColor Orange
    return
}

function Generate-Inno-Script {
    param(
        [string]$Arch,          # "x86" or "x64"
        [string]$SourceFolder,
        [string]$AppName,
        [string]$AppVersion
    )
    
    $IssPath = Join-Path $NWJS_DIR "installer-$Arch.iss"
    $OutputDir = Join-Path $NWJS_DIR "output"
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    
    $IssContent = @"
#define MyAppName "$AppName"
#define MyAppVersion "$AppVersion"
#define MyAppPublisher "Al-Mohandis"
#define MyAppExeName "nw.exe"
#define MyArch "$Arch"

[Setup]
AppId={{C782F456-621B-4A1C-89E2-7489A1EF06$Arch}}
AppName={#MyAppName} ({#MyArch})
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=$OutputDir
OutputBaseFilename=AlMohandisPOS-Legacy-{#MyArch}-{#MyAppVersion}-Installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Tasks]
Name: "desktopicon"; Description: "{group}\{#MyAppName}"; GroupDescription: "{group}"; Flags: unchecked

[Files]
Source: "$SourceFolder\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName} ({#MyArch})"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
"@

    $IssContent | Set-Content $IssPath -Force
    Write-Host "Generated ISS script: $IssPath" -ForegroundColor Green
    
    # Run ISCC
    Write-Host "Compiling installer for $Arch using Inno Setup..." -ForegroundColor Cyan
    & $ISCC_PATH $IssPath
}

$X86_SOURCE = Join-Path $X86_STAGE "nwjs-v$NWJS_VERSION-win-ia32"
$X64_SOURCE = Join-Path $X64_STAGE "nwjs-v$NWJS_VERSION-win-x64"

Generate-Inno-Script -Arch "x86" -SourceFolder $X86_SOURCE -AppName "AlMohandisPOS-Legacy" -AppVersion "1.0.0"
Generate-Inno-Script -Arch "x64" -SourceFolder $X64_SOURCE -AppName "AlMohandisPOS-Legacy" -AppVersion "1.0.0"

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host "Packaging Complete!" -ForegroundColor Green
Write-Host "Installers generated under: $NWJS_DIR\output\" -ForegroundColor Green
Write-Host "1. AlMohandisPOS-Legacy-x86-1.0.0-Installer.exe (32-bit & Windows 7/8/10/11 compatibility)" -ForegroundColor Green
Write-Host "2. AlMohandisPOS-Legacy-x64-1.0.0-Installer.exe (64-bit & Windows 7/8/10/11 compatibility)" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
