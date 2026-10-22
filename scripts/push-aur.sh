#!/usr/bin/env bash
# Publish aur/ to the AUR. Requires an AUR account with this machine's SSH key
# registered at https://aur.archlinux.org/account/
#
# Usage: ./scripts/push-aur.sh
# Optional: AUR_WORKDIR=/path/to/checkout ./scripts/push-aur.sh

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
aur_remote="ssh://aur@aur.archlinux.org/al-quran-multilingual-bin.git"
workdir="${AUR_WORKDIR:-$repo_root/../aur-al-quran-multilingual-bin}"
pkgbuild="$repo_root/aur/PKGBUILD"

pkgver="$(sed -n 's/^pkgver=//p' "$pkgbuild")"
pkgrel="$(sed -n 's/^pkgrel=//p' "$pkgbuild")"

if ! ssh -o BatchMode=yes -o ConnectTimeout=15 -T aur@aur.archlinux.org 2>&1 |
  grep -q "successfully authenticated"; then
  cat >&2 <<EOF
AUR SSH authentication failed.

Register this public key at https://aur.archlinux.org/account/ :

$(cat "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || echo "(no ~/.ssh/id_ed25519.pub found)")

Then re-run: $0
EOF
  exit 1
fi

if [[ ! -d "$workdir/.git" ]]; then
  if ! git clone "$aur_remote" "$workdir" 2>/dev/null; then
    mkdir -p "$workdir"
    git -C "$workdir" init -b master
    git -C "$workdir" remote add origin "$aur_remote"
  fi
fi

cp "$repo_root/aur/PKGBUILD" "$workdir/PKGBUILD"
cp "$repo_root/aur/.SRCINFO" "$workdir/.SRCINFO"
cp "$repo_root/aur/al-quran-multilingual.desktop" "$workdir/al-quran-multilingual.desktop"

(
  cd "$workdir"
  makepkg --printsrcinfo > .SRCINFO
  git add PKGBUILD .SRCINFO al-quran-multilingual.desktop
  if git diff --cached --quiet; then
    echo "AUR package is already up to date."
    exit 0
  fi
  git commit -m "upgpkg: al-quran-multilingual-bin ${pkgver}-${pkgrel}"
  git push origin master
)
