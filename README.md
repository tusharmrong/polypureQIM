# Poly Pure PWA

This folder contains an installable web app for quotations, invoices, and money receipts for Poly Pure.

## Files

- `index.html`: Main app
- `manifest.json`: PWA install metadata
- `service-worker.js`: Offline caching support
- `icon.svg`, `icon-192.svg`, `icon-512.svg`: App icons
- `release.json`: Release manager control file
- `RELEASE_MANAGER.md`: Release manager guide
- `release-patch.bat`, `release-minor.bat`, `release-major.bat`: One-click release launchers

## GitHub Pages hosting

1. Create a public GitHub repository
2. Upload the contents of this folder to the repository root
3. Turn on GitHub Pages from the `main` branch and `/ (root)` folder
4. Open the published GitHub Pages URL and test the app

## Update workflow

1. Edit the app files in this folder.
2. Double-click `release-patch.bat`
3. Re-upload the folder or push the updated files.

## Backup folder

The `backups/` folder is for keeping snapshots of working releases so you can roll back if needed.
