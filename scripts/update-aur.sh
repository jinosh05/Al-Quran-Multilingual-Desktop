#!/usr/bin/env bash
# Update the AppImage checksum and AUR metadata for a new release.
#
# Usage: ./scripts/update-aur.sh <version>
# Example: ./scripts/update-aur.sh 1.5.0
#
# Run this after replacing linux/Al_Quran_Multilingual-x86_64.AppImage with the
# new release build. It does not build the Flutter application.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

version="${1:-}"
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "usage: $0 <version>   (example: 1.5.0)" >&2
  exit 1
fi

appimage="linux/Al_Quran_Multilingual-x86_64.AppImage"
pkgbuild="aur/PKGBUILD"

[[ -f "$appimage" ]] || { echo "missing $appimage" >&2; exit 1; }
[[ -f "$pkgbuild" ]] || { echo "missing $pkgbuild" >&2; exit 1; }

sha256="$(sha256sum "$appimage" | awk '{print $1}')"
desktop_sha256="$(sha256sum "aur/al-quran-multilingual.desktop" | awk '{print $1}')"

# Keep the release checksum file in sync.
(
  cd linux
  sha256sum "Al_Quran_Multilingual-x86_64.AppImage" > SHA256SUMS
)

# Update pkgver and both checksums in place.
sed -i "s/^pkgver=.*/pkgver=${version}/" "$pkgbuild"
perl -0pi -e "s/(sha256sums=\(\n\s*')[0-9a-f]{64}(\n\s*')[0-9a-f]{64}/\${1}${sha256}\${2}${desktop_sha256}/" "$pkgbuild"

# Regenerate .SRCINFO from the PKGBUILD.
(
  cd aur
  makepkg --printsrcinfo > .SRCINFO
)

echo "Updated AUR metadata:"
echo "  version: ${version}"
echo "  sha256:  ${sha256}"
echo
echo "Next steps:"
echo "  1. git add linux/SHA256SUMS linux/Al_Quran_Multilingual-x86_64.AppImage aur/"
echo "  2. git commit -m \"Release ${version}\""
echo "  3. git tag ${version} && git push origin main ${version}"
echo "  4. Push aur/ to ssh://aur@aur.archlinux.org/al-quran-multilingual-bin.git"
