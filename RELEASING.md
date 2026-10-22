# Releasing Al Quran Multilingual for Linux

This repository is the **release/binaries repository** for the desktop app. It
contains the compiled Linux AppImage, Windows installer, Flatpak bundle,
screenshots, and packaging metadata. The Flutter application source is not part
of this repository and is never included in the release assets.

## One-time AUR setup

1. Register at <https://aur.archlinux.org>.
2. Add the local SSH public key under **My Account → SSH Public Key**:

   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. Verify SSH access:

   ```bash
   ssh -T aur@aur.archlinux.org
   ```

4. Clone the AUR package repository (it is separate from GitHub):

   ```bash
   git clone ssh://aur@aur.archlinux.org/al-quran-multilingual-bin.git
   ```

## Release checklist

1. Build the Linux release from the private Flutter source tree.
2. Replace `linux/Al_Quran_Multilingual-x86_64.AppImage` with the new build.
   The AppImage must contain a valid `AppRun` and start on a clean Arch system.
3. Update the AUR metadata and checksums:

   ```bash
   ./scripts/update-aur.sh 1.5.0
   ```

4. Commit, tag, and push. The tag **must** match `pkgver` in `aur/PKGBUILD`:

   ```bash
   git add README.md linux/ aur/ scripts/
   git commit -m "Release 1.5.0"
   git tag 1.5.0
   git push origin main 1.5.0
   ```

   The `.github/workflows/release.yml` workflow validates the checksum,
   smoke-tests the AppImage, and publishes the GitHub Release with the
   AppImage and `SHA256SUMS` asset.

5. Push the updated AUR package:

   ```bash
   cd /path/to/al-quran-multilingual-bin
   cp /path/to/Al-Quran-Multilingual-Desktop/aur/PKGBUILD .
   cp /path/to/Al-Quran-Multilingual-Desktop/aur/.SRCINFO .
   cp /path/to/Al-Quran-Multilingual-Desktop/aur/al-quran-multilingual.desktop .
   git add PKGBUILD .SRCINFO al-quran-multilingual.desktop
   git commit -m "upgpkg: al-quran-multilingual-bin 1.5.0-1"
   git push
   ```

## Why the AUR package is `-bin`

`al-quran-multilingual-bin` downloads the prebuilt AppImage from the GitHub
Release, extracts it to `/opt/al-quran-multilingual-bin`, and installs a
launcher, desktop entry, and icon. It never downloads a source archive, never
runs `flutter build`, and never installs `.dart` files. This keeps the Flutter
source private while still providing a native Arch Linux installation path.

## Verifying a release locally

```bash
cd /path/to/al-quran-multilingual-bin
makepkg -f
sudo pacman -U al-quran-multilingual-bin-1.5.0-1-x86_64.pkg.tar.zst
al-quran-multilingual
```

To test without installing:

```bash
makepkg -f
bsdtar tf al-quran-multilingual-bin-*.pkg.tar.zst | grep -E '\.dart$|pubspec' # must print nothing
```
