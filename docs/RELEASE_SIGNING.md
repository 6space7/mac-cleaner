# Release Signing

Mac Cleaner can build public release DMGs without Apple credentials, but signed and notarized releases need a Developer ID certificate plus Apple notarization credentials.

Do not commit certificates, passwords, `.env` files, or exported key material to this repository. Store them as GitHub Actions secrets.

## GitHub Secrets

Configure these repository secrets:

| Secret | Purpose |
| --- | --- |
| `APPLE_DEVELOPER_ID_CERTIFICATE_BASE64` | Base64-encoded `.p12` Developer ID Application certificate |
| `APPLE_DEVELOPER_ID_CERTIFICATE_PASSWORD` | Password for the `.p12` certificate |
| `APPLE_KEYCHAIN_PASSWORD` | Temporary CI keychain password |
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `APPLE_ID` | Apple ID used for notarization |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password for `notarytool` |
| `SPARKLE_ED_PRIVATE_KEY` | Private EdDSA key used to sign the Sparkle appcast |

The workflow never prints these values. It only imports them inside the runner's temporary keychain.

Tag releases require `SPARKLE_ED_PRIVATE_KEY` so installed apps can verify automatic updates. See [Auto Update](AUTO_UPDATE.md) for the updater feed details.

## Local Checks

Check whether a Developer ID Application identity is installed:

```bash
security find-identity -p codesigning -v
```

Build the app without distribution signing:

```bash
xcodebuild \
  -project mac-cleaner.xcodeproj \
  -scheme mac-cleaner \
  -configuration Release \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

After a signed release build, verify the app bundle:

```bash
codesign -dvvv --entitlements :- path/to/mac-cleaner.app
spctl -a -vv path/to/mac-cleaner.app
```

For a fully trusted public download, both the app bundle and the DMG should be signed/notarized where applicable, and stapled.
