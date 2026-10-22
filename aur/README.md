# AUR package — `al-quran-multilingual-bin`

Arch Linux package for the **prebuilt** Linux AppImage of Al Quran Multilingual.

The package is intentionally binary-only (`-bin`):

- It downloads the published AppImage from GitHub Releases.
- It extracts the already-compiled application into `/opt/al-quran-multilingual-bin`.
- It does **not** download, build, or redistribute the Flutter source code.
- The release asset contains no `.dart` sources, `pubspec.yaml`, or build metadata.

## Install (once the package is published on AUR)

```bash
yay -S al-quran-multilingual-bin
# or
paru -S al-quran-multilingual-bin
```

## Publish / update the package

The easiest path is the helper script from the release repository:

```bash
./scripts/push-aur.sh
```

It clones the AUR repository, copies `PKGBUILD`, `.SRCINFO`, and the desktop
entry, regenerates `.SRCINFO`, commits, and pushes.

<details>
<summary>Manual push</summary>

The AUR repository is separate from this GitHub repository and is pushed over
SSH:

```bash
git clone ssh://aur@aur.archlinux.org/al-quran-multilingual-bin.git
cd al-quran-multilingual-bin
cp /path/to/Al-Quran-Multilingual-Desktop/aur/PKGBUILD .
cp /path/to/Al-Quran-Multilingual-Desktop/aur/.SRCINFO .
cp /path/to/Al-Quran-Multilingual-Desktop/aur/al-quran-multilingual.desktop .
git add PKGBUILD .SRCINFO al-quran-multilingual.desktop
git commit -m "upgpkg: al-quran-multilingual-bin 1.5.0-1"
git push
```

</details>

`aur.archlinux.org` authenticates with an SSH key, not a password. The public
key must be registered under **My Account** on <https://aur.archlinux.org>:

```bash
cat ~/.ssh/id_ed25519.pub
```

Check access with:

```bash
ssh -T aur@aur.archlinux.org
```

A successful response looks like:

```text
Hi <username>! You've successfully authenticated, but the AUR shell is not available.
```

## Updating for a new upstream release

1. Replace `linux/Al_Quran_Multilingual-x86_64.AppImage` in the GitHub repo.
2. Update `linux/SHA256SUMS`.
3. Run `./scripts/update-aur.sh <version>` from the repository root.
4. Commit, tag the release, and push (the GitHub Actions workflow creates the
   release asset that the AUR package downloads).
5. Commit and push the AUR repository.

The GitHub release tag must match `pkgver` in `PKGBUILD`; the `source` URL uses
the tag directly.
