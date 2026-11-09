#!/usr/bin/env bash
# Ediciones sencillas con ffmpeg. Lee de VIDEOS_EN_BRUTO/ y guarda en VIDEOS_FINALIZADOS/.
# Los nombres de archivo pueden ir con o sin la carpeta VIDEOS_EN_BRUTO/ delante.
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
BRUTO="$RAIZ/VIDEOS_EN_BRUTO"
FINAL="$RAIZ/VIDEOS_FINALIZADOS"
X264=(-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart)

ayuda() {
cat <<'TXT'
Uso: scripts/editar.sh <comando> [argumentos]

  info       <video>                          Duracion, resolucion, fps
  recortar   <video> <inicio> <fin> [salida]  Corta un tramo (tiempos 00:01:30 o 90)
  unir       <salida> <video1> <video2> ...   Une varios clips en uno
  vertical   <video> [salida]                 Formato 9:16 (Shorts/TikTok/Reels) con fondo difuminado
  comprimir  <video> [salida]                 Reduce el peso (1080p, buena calidad)
  velocidad  <video> <factor> [salida]        Acelera/ralentiza (2 = el doble de rapido, 0.5 = camara lenta)
  sin-audio  <video> [salida]                 Quita el sonido
  musica     <video> <audio> [volumen] [sal]  Mezcla musica de fondo (volumen 0.0-1.0, por defecto 0.25)
  texto      <video> "<texto>" [salida]       Titulo arriba durante los primeros 4 segundos
  miniatura  <video> <tiempo> [salida.jpg]    Saca un fotograma como imagen
TXT
}

ruta() { # busca el archivo tal cual o dentro de VIDEOS_EN_BRUTO / VIDEOS_FINALIZADOS
  for p in "$1" "$BRUTO/$1" "$FINAL/$1"; do [ -f "$p" ] && { echo "$p"; return; }; done
  echo "No encuentro el archivo: $1" >&2; exit 1
}
base() { local b; b="$(basename "$1")"; echo "${b%.*}"; }
salida() { [ -n "${2:-}" ] && echo "$FINAL/$(basename "$2")" || echo "$FINAL/$(base "$1")_$3.mp4"; }

CMD="${1:-}"; shift || true
case "$CMD" in
  info)
    IN=$(ruta "$1")
    ffprobe -v error -show_entries format=duration,size:stream=codec_type,width,height,r_frame_rate -of default=nw=1 "$IN" ;;
  recortar)
    IN=$(ruta "$1"); OUT=$(salida "$IN" "${4:-}" "recorte")
    ffmpeg -y -ss "$2" -to "$3" -i "$IN" "${X264[@]}" "$OUT" ;;
  unir)
    OUT="$FINAL/$(basename "$1")"; shift
    LISTA=$(mktemp); trap 'rm -f "$LISTA"' EXIT
    INPUTS=(); FILTRO=""; i=0
    for v in "$@"; do INPUTS+=(-i "$(ruta "$v")"); FILTRO+="[$i:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=60[v$i];[$i:a]aresample=48000[a$i];"; i=$((i+1)); done
    for ((j=0;j<i;j++)); do FILTRO+="[v$j][a$j]"; done
    FILTRO+="concat=n=$i:v=1:a=1[v][a]"
    ffmpeg -y "${INPUTS[@]}" -filter_complex "$FILTRO" -map "[v]" -map "[a]" "${X264[@]}" "$OUT" ;;
  vertical)
    IN=$(ruta "$1"); OUT=$(salida "$IN" "${2:-}" "vertical")
    ffmpeg -y -i "$IN" -filter_complex \
      "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=20:2[fondo];[0:v]scale=1080:-2[frente];[fondo][frente]overlay=(W-w)/2:(H-h)/2" \
      "${X264[@]}" "$OUT" ;;
  comprimir)
    IN=$(ruta "$1"); OUT=$(salida "$IN" "${2:-}" "comprimido")
    ffmpeg -y -i "$IN" -vf "scale='min(1920,iw)':-2" -c:v libx264 -preset slow -crf 26 -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart "$OUT" ;;
  velocidad)
    IN=$(ruta "$1"); F="$2"; OUT=$(salida "$IN" "${3:-}" "x$F")
    # atempo admite 0.5-2.0 por paso: se encadenan pasos para factores mayores/menores
    A=""; R="$F"
    while awk "BEGIN{exit !($R>2.0)}"; do A+="atempo=2.0,"; R=$(awk "BEGIN{print $R/2.0}"); done
    while awk "BEGIN{exit !($R<0.5)}"; do A+="atempo=0.5,"; R=$(awk "BEGIN{print $R/0.5}"); done
    A+="atempo=$R"
    ffmpeg -y -i "$IN" -filter_complex "[0:v]setpts=PTS/$F[v];[0:a]$A[a]" -map "[v]" -map "[a]" "${X264[@]}" "$OUT" ;;
  sin-audio)
    IN=$(ruta "$1"); OUT=$(salida "$IN" "${2:-}" "sin-audio")
    ffmpeg -y -i "$IN" -c:v copy -an "$OUT" ;;
  musica)
    IN=$(ruta "$1"); AU=$(ruta "$2"); VOL="${3:-0.25}"; OUT=$(salida "$IN" "${4:-}" "musica")
    ffmpeg -y -i "$IN" -stream_loop -1 -i "$AU" -filter_complex \
      "[1:a]volume=$VOL[m];[0:a][m]amix=inputs=2:duration=first:dropout_transition=2[a]" \
      -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -shortest "$OUT" ;;
  texto)
    IN=$(ruta "$1"); OUT=$(salida "$IN" "${3:-}" "texto")
    TXTF=$(mktemp); trap 'rm -f "$TXTF"' EXIT; printf '%s' "$2" > "$TXTF"
    FUENTE=$(fc-match -f '%{file}' 'DejaVu Sans:bold' 2>/dev/null || true)
    ffmpeg -y -i "$IN" -vf "drawtext=textfile=$TXTF${FUENTE:+:fontfile=$FUENTE}:fontcolor=white:fontsize=h/14:borderw=4:bordercolor=black:x=(w-text_w)/2:y=h*0.08:enable=lt(t\\,4)" "${X264[@]}" "$OUT" ;;
  miniatura)
    IN=$(ruta "$1"); OUT="${3:-$(base "$IN")_miniatura.jpg}"; OUT="$FINAL/$(basename "$OUT")"
    ffmpeg -y -ss "$2" -i "$IN" -frames:v 1 -q:v 2 "$OUT" ;;
  ""|-h|--help|ayuda) ayuda ;;
  *) echo "Comando desconocido: $CMD"; ayuda; exit 1 ;;
esac
[ -n "${OUT:-}" ] && [ -f "$OUT" ] && echo ">> Guardado en: ${OUT#$RAIZ/}" || true
