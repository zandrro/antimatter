#!/bin/bash

set -ouex pipefail

### Install packages

FEDORA_PACKAGES=(
    fastfetch
    emacs
    ffmpeg
    mpv
    yt-dlp
    fish
    rust-analyzer
    libavutil
    maildir-utils
    isync
    msmtp
    transmission-cli
    playerctl
    libvterm
)

dnf5 -y install "${FEDORA_PACKAGES[@]}"

EXCLUDED_PACKAGES=(
    fedora-bookmarks
    fedora-chromium-config
    fedora-chromium-config-kde
    firefox
    firefox-langpacks
    firewall-config
    kcharselect
    krfb
    krfb-libs
    plasma-discover-kns
    plasma-welcome-fedora
    podman-docker
    kwrite
    kate
)

# Remove excluded packages if they are installed
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    readarray -t INSTALLED_EXCLUDED < <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}" 2>/dev/null || true)
    if [[ "${#INSTALLED_EXCLUDED[@]}" -gt 0 ]]; then
        dnf5 -y remove "${INSTALLED_EXCLUDED[@]}"
    else
        echo "No excluded packages found to remove."
    fi
fi

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

curl -fsSL https://repo.librewolf.net/librewolf.repo | tee /etc/yum.repos.d/librewolf.repo
dnf5 -y install librewolf

mkdir -p /usr/local/bin
EMACS_LSP_BOOSTER="$(curl -Ls https://api.github.com/repos/blahgeek/emacs-lsp-booster/releases/latest | jq -r '.assets[] | select(.name| test(".*musl.zip$")).browser_download_url')" || (true && sleep 5)
curl --retry 3 -L#o /tmp/emacs-lsp-booster.zip "$EMACS_LSP_BOOSTER"
unzip -d /usr/local/bin/ /tmp/emacs-lsp-booster.zip
rm -f /tmp/emacs-lsp-booster.zip
