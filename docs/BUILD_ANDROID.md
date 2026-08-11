# Build the DSS Lets Android APK (with branded icon)

Step-by-step runbook for building the DSS Lets Android APK on the owner's Mac.
This produces an APK whose launcher icon is the DSS Lets gold key on navy —
generated from the branded assets in this repo (`assets/icon/`) via
`flutter_launcher_icons`.

---

## 1. Pre-requisites

- **Flutter SDK installed** on the Mac (you already build from this repo on
  your Mac, so this is in place).
- **Android toolchain configured** — run `flutter doctor` and confirm there are
  no blockers for Android (Android Studio / `sdkmanager` platforms + command
  line tools + a connected device or emulator if you want to test install).
- **The repo cloned on the Mac at your existing location** — i.e. the full
  Flutter project that contains the `android/` directory (and `web/`). This
  repo on GitHub intentionally tracks only `lib/`, `pubspec.yaml`, `docs/`,
  `scripts/` and `build/`; the `android/` folder lives only on your Mac and is
  where the launcher icons get regenerated.

> Note: the current repo on GitHub has no `android/` or `web/` directory — do
> not clone fresh into a new folder expecting them. Use your existing local
> project folder.

## 2. Pull the new icon work

On `main` in your local repo:

```bash
git pull
```

This brings in the branded icon assets (`assets/icon/app_icon.png`,
`assets/icon/app_icon_foreground.png`), the `flutter_launcher_icons`
configuration in `pubspec.yaml`, and this runbook.

## 3. Fetch dependencies

```bash
flutter pub get
```

Installs/refreshes packages, including `flutter_launcher_icons` (already
declared in `pubspec.yaml`).

## 4. Generate the launcher icons

```bash
dart run flutter_launcher_icons
```

This regenerates every launcher icon in
`android/app/src/main/res/mipmap-*/` plus the adaptive icon XML from the two
new assets:

- `app_icon.png` — full-bleed navy background with the gold key (used as the
  legacy/mipmap launcher icon).
- `app_icon_foreground.png` — transparent background with the gold key at 64%
  of the canvas, inside the adaptive-icon safe zone (used for the adaptive
  icon foreground, drawn over the navy `adaptive_icon_background`).

## 5. Build the APK

```bash
flutter build apk --release
```

- **`--release`** is the default recommendation: smaller APK, optimised,
  and the build you should distribute.
- Use **`flutter build apk --debug`** instead only if you want a debuggable
  build for quick testing on a device. Trade-off: debug APKs are larger and
  slower; do not distribute them to users.

## 6. Where the output lands

```
build/app/outputs/flutter-apk/app-release.apk
```

(For a debug build the file is `app-debug.apk` in the same folder.)

## 7. Upload the APK

1. Open https://c7b7e222e9fb29445b351d0712389bee.ctonew.app/upload in a
   browser.
2. Upload `app-release.apk` (or `app-debug.apk`).
3. **Name it `app-debug.apk`** — the site's download button and QR code
   currently point to `/app-debug.apk`. The team will place your uploaded file
   under that name so the existing download link and QR code keep working
   without a site change.
4. If you upload under a different name, say so in the upload form's comment
   field so the team knows to relink the download button/QR code to the new
   file name.

## 8. Sanity checklist

After `dart run flutter_launcher_icons`:

- [ ] `android/app/src/main/res/` contains regenerated `mipmap-*/ic_launcher.png`
      files (check `mipmap-mdpi`, `mipmap-hdpi`, `mipmap-xhdpi`,
      `mipmap-xxhdpi`, `mipmap-xxxhdpi`).
- [ ] The adaptive icon XML references the navy background:
      `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` uses
      `@color/ic_launcher_background` (or a navy drawable) and the gold-key
      foreground — i.e. navy `#0A2342` background + gold key, no text.

After installing the APK:

- [ ] The launcher shows the DSS Lets gold key icon on a navy background.
- [ ] The icon renders correctly on both standard and adaptive-icon launchers
      (round/squircle masks on modern Android clip the gold key only if it
      extends beyond the safe zone — it doesn't).
