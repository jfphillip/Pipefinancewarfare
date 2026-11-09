#!/usr/bin/env bash
# Instala las herramientas necesarias (ffmpeg + yt-dlp). Se ejecuta solo al iniciar una sesion de Claude.
set -euo pipefail
if ! command -v ffmpeg >/dev/null 2>&1; then
  (apt-get update -qq && apt-get install -y -qq ffmpeg) >/dev/null 2>&1 || echo "Aviso: no se pudo instalar ffmpeg" >&2
fi
if ! command -v yt-dlp >/dev/null 2>&1; then
  pip install -q -U yt-dlp >/dev/null 2>&1 || echo "Aviso: no se pudo instalar yt-dlp" >&2
fi
git lfs install --local >/dev/null 2>&1 || true
exit 0
