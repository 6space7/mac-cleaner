# Auto Update

Mac Cleaner uses Sparkle 2 for automatic updates outside the Mac App Store.

## Runtime

- The app embeds Sparkle through Swift Package Manager.
- `SPUStandardUpdaterController` starts when the app launches.
- Users can run **Mac Cleaner > Check for Updates...** from the app menu.
- Automatic update checks are enabled by default.
- The app reads updates from:

```text
https://github.com/6space7/mac-cleaner/releases/latest/download/appcast.xml
```

## Release Feed

Tag releases generate and attach:

- `Mac-Cleaner-vX.Y.Z-apple-silicon.dmg`
- `Mac-Cleaner-vX.Y.Z-intel.dmg`
- `Mac-Cleaner-vX.Y.Z-universal.dmg`
- `appcast.xml`
- Sparkle delta files when Sparkle can generate them

Sparkle uses the universal DMG in the appcast. The architecture-specific DMGs are still published as direct downloads.

Sparkle verifies updates with the public EdDSA key embedded in the app bundle.
The private EdDSA key must stay in GitHub Actions secrets as:

```text
SPARKLE_ED_PRIVATE_KEY
```

Do not commit the private key to the repository.

## Release Checklist

Before tagging a new release:

1. Bump `MARKETING_VERSION` if the public app version changes.
2. Bump `CURRENT_PROJECT_VERSION`; Sparkle uses this build number to compare updates.
3. Push a version tag such as `v1.0.2`.
4. Confirm the release contains both DMGs and `appcast.xml`.
