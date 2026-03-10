# APK Size Analysis — devtools_companion

## Baseline

| Build | Size |
|-------|------|
| **Release APK** (arm64) | **19.77 MB** |
| Debug APK | 87.34 MB |

## Findings & Reduction Opportunities

### 1. ⚠️ Unused dependency: `dio` (~200-400 KB estimated)
`dio` is declared in `pubspec.yaml` but **never imported** anywhere in `lib/`. It can be safely removed.

### 2. ⚠️ Redundant dependency: `flutter_driver` in production (~adds transitive deps)
`flutter_driver` is listed under `dependencies:` but it's only used in [driver_main.dart](file:///c:/Users/penqu/work/devtools_companion/lib/driver_main.dart) (a test/driver entrypoint). It should be moved to `dev_dependencies:` so it's not bundled in the release APK.

### 3. 🔤 Custom fonts: **1.51 MB** (11 TTF files)
The app bundles 6 Roboto weights and 5 RobotoMono weights. However:
- **Roboto-Thin (w100)** and **Roboto-Black (w900)** are **never used** in the codebase — removing them saves ~335 KB.
- Roboto is already the default system font on Android, so the entire Roboto family could potentially be removed (~1 MB saved) and rely on the platform font. RobotoMono would still need to be bundled for monospace.

### 4. 🎨 Material Icons font (~1 MB)
`uses-material-design: true` bundles the full MaterialIcons-Regular.otf (~1 MB). If the app only uses a handful of icons, you could switch to individual SVG/PNG icons instead.

### 5. 🔀 `--split-debug-info` + `--obfuscate` (~5-15% reduction)
Building with these flags strips debug symbols from the release binary:
```bash
flutter build apk --split-debug-info=build/symbols/ --obfuscate --target-platform android-arm64
```

### Summary of Potential Savings

| Optimization | Estimated Savings |
|---|---|
| Remove unused `dio` dependency | ~200-400 KB |
| Move `flutter_driver` to dev_dependencies | ~100-300 KB |
| Remove unused font weights (Thin, Black) | ~335 KB |
| Remove all bundled Roboto (use system font) | ~1 MB |
| `--split-debug-info` + `--obfuscate` | ~1-3 MB |
| **Total potential** | **~2-5 MB (10-25%)** |
