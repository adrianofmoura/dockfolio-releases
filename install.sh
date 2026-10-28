#!/bin/bash
# Instalador do Dockfolio pelo Terminal. Baixa a versão mais recente e a instala em Aplicativos.
#   curl -fsSL https://adrianofmoura.github.io/dockfolio-releases/install.sh | bash
# Arquivos baixados com o curl não recebem a marca de quarentena do macOS, então o app abre sem o aviso do Gatekeeper.
# As mensagens saem no idioma do macOS (10 idiomas; inglês como reserva).
# (O endereço abaixo vem do release.sh; DOCKFOLIO_FEED, DOCKFOLIO_DEST e DOCKFOLIO_LANG servem para testar.)
set -euo pipefail

FEED="${DOCKFOLIO_FEED:-https://adrianofmoura.github.io/dockfolio-releases}"

# Idioma do macOS: o primeiro de AppleLanguages (ex.: pt-BR → pt).
SYS="${DOCKFOLIO_LANG:-$(defaults read -g AppleLanguages 2>/dev/null | sed -n '2p' | tr -d ' ",' || true)}"
case "${SYS%%[-_]*}" in
  pt) L=pt;; es) L=es;; fr) L=fr;; de) L=de;; it) L=it;; ja) L=ja;; ko) L=ko;; zh) L=zh;; ru) L=ru;; *) L=en;;
esac

# m <chave>: a mensagem no idioma escolhido.
m() {
  case "$L:$1" in
    pt:finding) echo "Procurando a versão mais recente…";;
    pt:download) echo "Baixando";;
    pt:installed) echo "Dockfolio %s instalado em %s.";;
    pt:err_mac) echo "O Dockfolio é só para macOS.";;
    pt:err_os) echo "O Dockfolio precisa do macOS 12 (Monterey) ou mais novo.";;
    pt:err_feed) echo "Não encontrei o download no feed.";;
    pt:err_zip) echo "O arquivo baixado não tem o Dockfolio.app.";;
    pt:err_sig) echo "A assinatura do app não confere.";;
    es:finding) echo "Buscando la versión más reciente…";;
    es:download) echo "Descargando";;
    es:installed) echo "Dockfolio %s instalado en %s.";;
    es:err_mac) echo "Dockfolio es solo para macOS.";;
    es:err_os) echo "Dockfolio necesita macOS 12 (Monterey) o posterior.";;
    es:err_feed) echo "No encontré la descarga en el feed.";;
    es:err_zip) echo "El archivo descargado no contiene Dockfolio.app.";;
    es:err_sig) echo "La firma de la app no coincide.";;
    fr:finding) echo "Recherche de la dernière version…";;
    fr:download) echo "Téléchargement de";;
    fr:installed) echo "Dockfolio %s installé dans %s.";;
    fr:err_mac) echo "Dockfolio est réservé à macOS.";;
    fr:err_os) echo "Dockfolio nécessite macOS 12 (Monterey) ou ultérieur.";;
    fr:err_feed) echo "Téléchargement introuvable dans le flux.";;
    fr:err_zip) echo "Le fichier téléchargé ne contient pas Dockfolio.app.";;
    fr:err_sig) echo "La signature de l’app ne correspond pas.";;
    de:finding) echo "Suche nach der neuesten Version …";;
    de:download) echo "Lade";;
    de:installed) echo "Dockfolio %s wurde in %s installiert.";;
    de:err_mac) echo "Dockfolio gibt es nur für macOS.";;
    de:err_os) echo "Dockfolio benötigt macOS 12 (Monterey) oder neuer.";;
    de:err_feed) echo "Download im Feed nicht gefunden.";;
    de:err_zip) echo "Die heruntergeladene Datei enthält kein Dockfolio.app.";;
    de:err_sig) echo "Die Signatur der App stimmt nicht überein.";;
    it:finding) echo "Cerco l’ultima versione…";;
    it:download) echo "Scarico";;
    it:installed) echo "Dockfolio %s installato in %s.";;
    it:err_mac) echo "Dockfolio è solo per macOS.";;
    it:err_os) echo "Dockfolio richiede macOS 12 (Monterey) o successivo.";;
    it:err_feed) echo "Download non trovato nel feed.";;
    it:err_zip) echo "Il file scaricato non contiene Dockfolio.app.";;
    it:err_sig) echo "La firma dell’app non corrisponde.";;
    ja:finding) echo "最新バージョンを探しています…";;
    ja:download) echo "ダウンロード中:";;
    ja:installed) echo "Dockfolio %s を %s にインストールしました。";;
    ja:err_mac) echo "DockfolioはmacOS専用です。";;
    ja:err_os) echo "DockfolioにはmacOS 12（Monterey）以降が必要です。";;
    ja:err_feed) echo "フィードにダウンロードが見つかりません。";;
    ja:err_zip) echo "ダウンロードしたファイルにDockfolio.appがありません。";;
    ja:err_sig) echo "Appの署名が一致しません。";;
    ko:finding) echo "최신 버전을 찾는 중…";;
    ko:download) echo "다운로드 중:";;
    ko:installed) echo "Dockfolio %s을(를) %s에 설치했습니다.";;
    ko:err_mac) echo "Dockfolio는 macOS 전용입니다.";;
    ko:err_os) echo "Dockfolio에는 macOS 12(Monterey) 이상이 필요합니다.";;
    ko:err_feed) echo "피드에서 다운로드를 찾지 못했습니다.";;
    ko:err_zip) echo "다운로드한 파일에 Dockfolio.app이 없습니다.";;
    ko:err_sig) echo "앱 서명이 일치하지 않습니다.";;
    zh:finding) echo "正在查找最新版本…";;
    zh:download) echo "正在下载";;
    zh:installed) echo "Dockfolio %s 已安装到 %s。";;
    zh:err_mac) echo "Dockfolio 仅适用于 macOS。";;
    zh:err_os) echo "Dockfolio 需要 macOS 12（Monterey）或更高版本。";;
    zh:err_feed) echo "在订阅源中找不到下载文件。";;
    zh:err_zip) echo "下载的文件中没有 Dockfolio.app。";;
    zh:err_sig) echo "App 的签名不匹配。";;
    ru:finding) echo "Ищу последнюю версию…";;
    ru:download) echo "Загрузка";;
    ru:installed) echo "Dockfolio %s установлен в %s.";;
    ru:err_mac) echo "Dockfolio работает только в macOS.";;
    ru:err_os) echo "Для Dockfolio нужна macOS 12 (Monterey) или новее.";;
    ru:err_feed) echo "Не нашёл загрузку в ленте.";;
    ru:err_zip) echo "В загруженном файле нет Dockfolio.app.";;
    ru:err_sig) echo "Подпись приложения не совпадает.";;
    en:finding) echo "Looking for the latest version…";;
    en:download) echo "Downloading";;
    en:installed) echo "Dockfolio %s installed in %s.";;
    en:err_mac) echo "Dockfolio is for macOS only.";;
    en:err_os) echo "Dockfolio needs macOS 12 (Monterey) or later.";;
    en:err_feed) echo "Couldn't find the download in the feed.";;
    en:err_zip) echo "The downloaded file doesn't contain Dockfolio.app.";;
    en:err_sig) echo "The app's signature doesn't match.";;
  esac
}

[ "$(uname)" = "Darwin" ] || { m err_mac; exit 1; }
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 12 ] || { m err_os; exit 1; }

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

m finding
curl -fsSL "$FEED/appcast.xml" -o "$TMP/appcast.xml"

# Do appcast, o .zip da versão de maior número (as linhas .delta são ignoradas).
URL="$(tr '\n' ' ' < "$TMP/appcast.xml" | sed 's#</item>#\
#g' | awk '
  match($0, /<sparkle:version>[0-9]+</)  { v = substr($0, RSTART + 17, RLENGTH - 18) + 0 }
  match($0, /enclosure url="[^"]*\.zip"/) { u = substr($0, RSTART + 15, RLENGTH - 16); if (v > best) { best = v; url = u } }
  END { print url }')"
[ -n "$URL" ] || { m err_feed; exit 1; }

echo "$(m download) $(basename "$URL")…"
curl -fL --progress-bar "$URL" -o "$TMP/Dockfolio.zip"
ditto -x -k "$TMP/Dockfolio.zip" "$TMP/unzipped"
[ -d "$TMP/unzipped/Dockfolio.app" ] || { m err_zip; exit 1; }

# Se já estiver aberto, fecha para poder substituir (não no modo de teste).
[ -n "${DOCKFOLIO_DEST:-}" ] || osascript -e 'tell application id "com.dockfolder.manager" to quit' >/dev/null 2>&1 || true

rm -rf "$DEST/Dockfolio.app"
ditto "$TMP/unzipped/Dockfolio.app" "$DEST/Dockfolio.app"
xattr -cr "$DEST/Dockfolio.app" 2>/dev/null || true
codesign --verify --deep "$DEST/Dockfolio.app" || { m err_sig; exit 1; }

VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$DEST/Dockfolio.app/Contents/Info.plist")"
printf "$(m installed)\n" "$VERSION" "$DEST"
[ -n "${DOCKFOLIO_DEST:-}" ] || open "$DEST/Dockfolio.app"
