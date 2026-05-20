# Mac Cleaner

Mac Cleaner is a native SwiftUI cache cleaner for macOS. It focuses on one job: find regenerable cache files, delete the safe ones, and stay quiet unless something actually needs attention.

The app is intentionally not a manual file picker. Press the center **Start** control and it runs a deep cache pass, skips protected macOS/iCloud locations, avoids active app caches, deletes recommended cache items, and keeps lightweight cleanup stats in the window and menu bar.

## Features

- One-click cache scan and cleanup with no tab maze or manual selection step.
- Deep cache catalog covering user caches, logs, browser storage, app containers, developer caches, package manager caches, AI/editor tool caches, communication apps, design/media apps, and old installer/archive files.
- Safety policy for Apple privacy areas such as CloudKit, FamilyCircle, TCC, Mail, Messages, Safari data, HomeKit, and Apple-owned containers.
- Active-process checks for app-specific caches so running apps such as Chrome, Arc, Slack, Spotify, VS Code, Cursor, Xcode, and others are not cleaned underneath themselves.
- Admin retry path for permission-restricted cache files.
- Auto Clean scheduler with 1h, 2h, 4h, 8h, and 12h intervals.
- Menu bar summary for last cleanup, total cleanup, current cache found, and next scheduled run.
- Native macOS UI built with SwiftUI.

## Safety Model

Mac Cleaner only auto-deletes items marked as recommended by the scanner. A cache candidate is recommended when it is in the cache catalog, is not protected by the privacy policy, is not blocked by a running app, and passes the location's age/risk rules.

Protected paths are filtered before deletion. That means privacy-sensitive areas and system-owned data should be skipped instead of repeatedly asking for permission.

High-risk custom locations are not part of the one-click cleanup path.

## Requirements

- macOS 15 or newer.
- Xcode with the macOS SDK installed.
- A Developer ID Application certificate and Apple notarization credentials are only needed for signed public releases.

## Run Locally

```bash
./script/build_and_run.sh
```

Verify the app builds and launches:

```bash
./script/build_and_run.sh --verify
```

Useful debugging modes:

```bash
./script/build_and_run.sh --logs
./script/build_and_run.sh --telemetry
./script/build_and_run.sh --debug
```

## CI/CD

This repository includes GitHub Actions for:

- `CI`: builds the macOS app on every push and pull request.
- `Release`: builds Apple Silicon and Intel DMGs on version tags such as `v1.0.0` or manual dispatch.
- Dependabot: keeps GitHub Actions versions fresh.

The release workflow creates unsigned DMGs if signing secrets are missing. When Apple signing secrets are configured, it imports the Developer ID certificate into a temporary keychain, builds with hardened runtime, notarizes and staples the app bundle, then notarizes and staples both DMGs.

See [Release Signing](docs/RELEASE_SIGNING.md) for the required secret names.

## Release

Create and push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The release workflow will attach these downloads when it is triggered by a tag:

- `Mac-Cleaner-vX.Y.Z-apple-silicon.dmg`
- `Mac-Cleaner-vX.Y.Z-intel.dmg`

## Project Structure

```text
mac-cleaner/
  Models/       Cleanup models, risk levels, scan profiles, intervals
  Services/     Cache catalog, scanning, protection policy, deletion service
  Stores/       App state, scanning, cleanup, scheduler
  Support/      Formatting helpers
  Views/        SwiftUI window, controls, metrics, menu bar UI
script/
  build_and_run.sh
.github/workflows/
  ci.yml
  release.yml
```
