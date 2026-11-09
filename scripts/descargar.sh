#!/usr/bin/env bash
# Descarga uno o varios videos desde un link (YouTube, Twitch, Kick, TikTok, X, Drive publico, etc.)
# Uso: scripts/descargar.sh <URL> [URL2 ...]
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
DESTINO="$RAIZ/VIDEOS_EN_BRUTO"
[ $# -ge 1 ] || { echo "Uso: $0 <URL> [URL2 ...]"; exit 1; }
command -v yt-dlp >/dev/null || pip install -q yt-dlp
EXTRA=()
command -v node >/dev/null && EXTRA+=(--js-runtimes node)          # ayuda con YouTube
[ -n "${COOKIES:-}" ] && EXTRA+=(--cookies "$COOKIES")             # opcional: COOKIES=/ruta/cookies.txt
for URL in "$@"; do
  echo ">> Descargando: $URL"
  yt-dlp \
    -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/bv*+ba/b" \
    --merge-output-format mp4 \
    --restrict-filenames "${EXTRA[@]}" \
    -o "$DESTINO/%(upload_date>%Y-%m-%d|sin-fecha)s_%(title).80s.%(ext)s" \
    "$URL"
done
echo ">> Listo. Archivos en VIDEOS_EN_BRUTO/:"
ls -lh "$DESTINO" | grep -v .gitkeep
