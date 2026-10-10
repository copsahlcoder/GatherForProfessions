# Builds a zip that other players can install:
#   dist\ProfessionPlanner-<version>.zip
# The version is read from "## Version:" in ProfessionPlanner.toc.
# The tests folder is left out (players don't need it).
#
# Run from the repository root:
#   powershell -ExecutionPolicy Bypass -File scripts\package.ps1

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$addon = Join-Path $root "ProfessionPlanner"
$toc = Join-Path $addon "ProfessionPlanner.toc"

# Read the version from the .toc file.
$versionLine = Select-String -Path $toc -Pattern "^## Version:\s*(.+)$" | Select-Object -First 1
if (-not $versionLine) {
    throw "Could not find '## Version:' in $toc"
}
$version = $versionLine.Matches[0].Groups[1].Value.Trim()

$dist = Join-Path $root "dist"
$staging = Join-Path $dist "staging"
$zip = Join-Path $dist "ProfessionPlanner-$version.zip"

# Start from a clean staging folder.
if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Force $staging | Out-Null

# Copy the addon, without tests. The zip must contain the folder
# "ProfessionPlanner" at the top, so players can unzip it straight into AddOns.
$target = Join-Path $staging "ProfessionPlanner"
Copy-Item -Recurse $addon $target
Remove-Item -Recurse -Force (Join-Path $target "tests")

# Safety check: refuse to package files that contain traces of this machine
# (user name, home folder, absolute Windows paths). The values are read from
# the machine running the script, so nothing personal is stored here.
$forbidden = @(
    [regex]::Escape($env:USERNAME),
    [regex]::Escape($env:USERPROFILE),
    "[A-Za-z]:\\Users\\",
    "Program Files"
)
$leaks = Get-ChildItem -Recurse -File $target | Select-String -Pattern $forbidden
if ($leaks) {
    Remove-Item -Recurse -Force $staging
    $leaks | ForEach-Object { Write-Host "  $($_.Path.Substring($staging.Length + 1)):$($_.LineNumber): $($_.Line.Trim())" }
    throw "Packaging stopped: the files above contain machine-specific paths or names."
}

if (Test-Path $zip) { Remove-Item -Force $zip }

# Build the zip by hand: Compress-Archive in Windows PowerShell 5.1 writes
# backslashes in paths, which breaks unzipping on Mac/Linux and some tools.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($zip, "Create")
try {
    foreach ($file in Get-ChildItem -Recurse -File $target) {
        $relative = $file.FullName.Substring($staging.Length + 1).Replace("\", "/")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $relative) | Out-Null
    }
} finally {
    $archive.Dispose()
}
Remove-Item -Recurse -Force $staging

Write-Host "Created $zip"
