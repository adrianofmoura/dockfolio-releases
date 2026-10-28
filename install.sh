#!/bin/bash
# Instalador do Dockfolio pelo Terminal. Baixa a versão mais recente e a instala em Aplicativos.
#   curl -fsSL https://adrianofmoura.github.io/dockfolio-releases/install.sh | bash
# Arquivos baixados com o curl não recebem a marca de quarentena do macOS, então o app abre sem o aviso do Gatekeeper.
# (O endereço abaixo vem do release.sh; DOCKFOLIO_FEED e DOCKFOLIO_DEST servem para testar.)
set -euo pipefail

FEED="${DOCKFOLIO_FEED:-https://adrianofmoura.github.io/dockfolio-releases}"

[ "$(uname)" = "Darwin" ] || { echo "O Dockfolio é só para macOS."; exit 1; }
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 12 ] || { echo "O Dockfolio precisa do macOS 12 (Monterey) ou mais novo."; exit 1; }

if [ -n "${DOCKFOLIO_DEST:-}" ]; then
  DEST="$DOCKFOLIO_DEST"
elif [ -w /Applications ]; then
  DEST="/Applications"
else
  DEST="$HOME/Applications"
fi
mkdir -p "$DEST"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Procurando a versão mais recente…"
curl -fsSL "$FEED/appcast.xml" -o "$TMP/appcast.xml"

# Do appcast, o .zip da versão de maior número (as linhas .delta são ignoradas).
URL="$(tr '\n' ' ' < "$TMP/appcast.xml" | sed 's#</item>#\
#g' | awk '
  match($0, /<sparkle:version>[0-9]+</)  { v = substr($0, RSTART + 17, RLENGTH - 18) + 0 }
  match($0, /enclosure url="[^"]*\.zip"/) { u = substr($0, RSTART + 15, RLENGTH - 16); if (v > best) { best = v; url = u } }
  END { print url }')"
[ -n "$URL" ] || { echo "Não encontrei o download no feed."; exit 1; }

echo "Baixando $(basename "$URL")…"
curl -fL --progress-bar "$URL" -o "$TMP/Dockfolio.zip"
ditto -x -k "$TMP/Dockfolio.zip" "$TMP/unzipped"
[ -d "$TMP/unzipped/Dockfolio.app" ] || { echo "O arquivo baixado não tem o Dockfolio.app."; exit 1; }

# Se já estiver aberto, fecha para poder substituir.
osascript -e 'tell application id "com.dockfolder.manager" to quit' >/dev/null 2>&1 || true

rm -rf "$DEST/Dockfolio.app"
ditto "$TMP/unzipped/Dockfolio.app" "$DEST/Dockfolio.app"
xattr -cr "$DEST/Dockfolio.app" 2>/dev/null || true
codesign --verify --deep "$DEST/Dockfolio.app" || { echo "A assinatura do app não confere."; exit 1; }

VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$DEST/Dockfolio.app/Contents/Info.plist")"
echo "Dockfolio $VERSION instalado em $DEST."
[ -n "${DOCKFOLIO_DEST:-}" ] || open "$DEST/Dockfolio.app"
