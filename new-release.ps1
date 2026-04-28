param(
    [ValidateSet("patch", "minor", "major")]
    [string]$Bump = "patch",
    [string]$ProjectRoot = $PSScriptRoot
)

function Get-NextVersion {
    param(
        [string]$CurrentVersion,
        [string]$BumpType
    )

    $parts = $CurrentVersion.Split(".")
    if ($parts.Count -ne 3) {
        throw "Version '$CurrentVersion' is invalid. Expected format: major.minor.patch"
    }

    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]

    switch ($BumpType) {
        "major" {
            $major += 1
            $minor = 0
            $patch = 0
        }
        "minor" {
            $minor += 1
            $patch = 0
        }
        default {
            $patch += 1
        }
    }

    return "$major.$minor.$patch"
}

$releaseFile = Join-Path $ProjectRoot "release.json"
$syncScript = Join-Path $ProjectRoot "sync-release.ps1"
$backupRoot = Join-Path $ProjectRoot "backups"

if (-not (Test-Path -LiteralPath $releaseFile)) {
    throw "release.json not found."
}

$release = Get-Content -LiteralPath $releaseFile -Raw | ConvertFrom-Json
$currentVersion = $release.version
$nextVersion = Get-NextVersion -CurrentVersion $currentVersion -BumpType $Bump
$today = Get-Date -Format "yyyy-MM-dd"
$backupFolderRelative = "backups/v$nextVersion"
$backupFolder = Join-Path $ProjectRoot $backupFolderRelative

New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
New-Item -ItemType Directory -Force -Path $backupFolder | Out-Null

$filesToBackup = @(
    "index.html",
    "manifest.json",
    "service-worker.js",
    "icon.svg",
    "icon-192.svg",
    "icon-512.svg",
    "README.md",
    "VERSION.md",
    "release.json",
    "RELEASE_MANAGER.md",
    "sync-release.ps1",
    "new-release.ps1",
    "release-patch.bat",
    "release-minor.bat",
    "release-major.bat"
)

foreach ($file in $filesToBackup) {
    $source = Join-Path $ProjectRoot $file
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination $backupFolder -Force
    }
}

$release.version = $nextVersion
$release.releaseDate = $today
$release.backupFolder = $backupFolderRelative

$existingNotes = @()
if ($release.releaseNotes) {
    $existingNotes = @($release.releaseNotes)
}

$release.releaseNotes = @("Auto-created $Bump release v$nextVersion on $today") + $existingNotes

$release.nextReleaseChecklist = @(
    "Run new-release.ps1 -Bump patch|minor|major",
    "Review release notes in release.json",
    "Upload updated folder to GitHub Pages or your static host"
)

$release | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $releaseFile -Encoding UTF8

& $syncScript -ProjectRoot $ProjectRoot

Write-Output "New release created successfully."
Write-Output "Previous version: $currentVersion"
Write-Output "New version: $nextVersion"
Write-Output "Backup folder: $backupFolderRelative"
