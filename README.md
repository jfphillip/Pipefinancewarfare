# Editor de gameplays

Repositorio para editar videos sencillos de gameplay con Claude Code.

```
VIDEOS_EN_BRUTO/      ← aqui van los videos originales (subidos o descargados)
VIDEOS_FINALIZADOS/   ← aqui quedan los videos editados
scripts/descargar.sh  ← descarga videos desde un link
scripts/editar.sh     ← ediciones rapidas con ffmpeg
scripts/setup.sh      ← instala ffmpeg y yt-dlp si faltan
```

## Como pasarme un video

**Opcion 1 – Un link.** Escribe en el chat: *"descarga este video: https://..."*.
Funciona con Twitch, Kick, TikTok, X/Twitter, Instagram, links directos a `.mp4`, y normalmente YouTube
(YouTube a veces bloquea las descargas desde servidores en la nube; si pasa, usa la opcion 2).

**Opcion 2 – Subir tu grabacion.**
- Video de menos de 25 MB: en GitHub entra a `VIDEOS_EN_BRUTO/` → *Add file* → *Upload files* → elige tu rama.
- Video mas grande (lo normal en gameplays): subelo desde tu PC con git.
  ```bash
  git lfs install
  ```
  ```bash
  cp /ruta/a/mi_gameplay.mp4 VIDEOS_EN_BRUTO/
  ```
  ```bash
  git add VIDEOS_EN_BRUTO/ && git commit -m "Nuevo gameplay" && git push
  ```
  Los videos se guardan con **Git LFS** (ver `.gitattributes`). El plan gratuito de GitHub da ~1 GB de LFS:
  borra los brutos ya editados si te quedas sin espacio.
- Alternativa: sube el video a Google Drive / Dropbox con enlace publico y pasame ese link (opcion 1).

Luego dime que hacer, por ejemplo: *"recorta del minuto 2:10 al 3:05 y ponlo vertical para TikTok"*.

## Ediciones disponibles

| Comando | Que hace |
|---|---|
| `info <video>` | Duracion, resolucion, fps |
| `recortar <video> <inicio> <fin>` | Corta un tramo |
| `unir <salida> <v1> <v2> ...` | Une clips (los iguala a 1080p 60fps) |
| `vertical <video>` | 9:16 para Shorts/TikTok/Reels con fondo difuminado |
| `comprimir <video>` | Reduce el peso |
| `velocidad <video> <factor>` | Acelera (2) o camara lenta (0.5) |
| `sin-audio <video>` | Quita el sonido |
| `musica <video> <audio> [volumen]` | Musica de fondo |
| `texto <video> "<texto>"` | Titulo los primeros 4 s |
| `miniatura <video> <tiempo>` | Fotograma como imagen |

Ejemplo: `scripts/editar.sh recortar partida.mp4 00:02:10 00:03:05`

## Skills de Claude

- **`editor-gameplay`** (incluida en `.claude/skills/`): el flujo de este repo (descargar → editar → guardar).
- **`youtube-edit`**: edicion avanzada (cortes por transcripcion, overlays, B-roll, render 4K).
- **`yt-shorts`**: encuentra los mejores momentos de un video largo para Shorts.
- **`yt-package`** / **`yt-seo`**: titulo, miniatura, descripcion y tags.
