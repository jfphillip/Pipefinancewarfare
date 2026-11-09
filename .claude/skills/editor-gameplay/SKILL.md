---
name: editor-gameplay
description: Descargar y editar videos sencillos de gameplay en este repositorio. Usar cuando el usuario pase un link de video, suba un gameplay, o pida recortar, unir, poner en vertical (Shorts/TikTok/Reels), comprimir, acelerar, quitar audio, poner musica o texto, o sacar una miniatura.
---

# Editor de gameplays

Flujo del repositorio:

0. **Preparar**: `bash scripts/setup.sh` (instala ffmpeg y yt-dlp si faltan).
1. **Entrada** → `VIDEOS_EN_BRUTO/`
   - Si el usuario da un link: `scripts/descargar.sh "<URL>"` (yt-dlp; vale YouTube, Twitch, Kick, TikTok, X, links directos .mp4...).
   - Si el usuario subio el video a GitHub: hacer `git pull` de la rama y `git lfs pull` para bajar el archivo real.
2. **Edicion** → `scripts/editar.sh <comando> ...` (ver `scripts/editar.sh ayuda`). Siempre escribe en `VIDEOS_FINALIZADOS/`.
3. **Comprobar** el resultado con `scripts/editar.sh info <archivo>` y, si hay dudas visuales, sacar un fotograma con `miniatura` y mirarlo.
4. **Entregar**: `git add VIDEOS_FINALIZADOS/<archivo>` → commit → push (los videos van por Git LFS segun `.gitattributes`).

Reglas:
- Nunca modificar ni borrar los originales de `VIDEOS_EN_BRUTO/` salvo que el usuario lo pida.
- Si el usuario no da tiempos exactos para recortar, preguntar o proponer tramos usando `info` y miniaturas en varios puntos.
- Para pedidos mas complejos (cortes por transcripcion, overlays animados, B-roll) usar la skill `anthropic-skills:youtube-edit`; para sacar Shorts de un video largo, `youtube-agent:yt-shorts`; titulos y miniaturas, `youtube-agent:yt-package`.
- YouTube a veces bloquea descargas desde la nube ("Sign in to confirm you're not a bot"). En ese caso pedir al usuario que suba el archivo a `VIDEOS_EN_BRUTO/` o que use otra plataforma / un link directo.
