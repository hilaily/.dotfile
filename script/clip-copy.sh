#!/usr/bin/env bash
# Copy stdin to the system clipboard (macOS / Linux X11 / Linux Wayland).

set -euo pipefail

if command -v pbcopy >/dev/null 2>&1; then
  pbcopy
elif [ "${XDG_SESSION_TYPE:-}" = wayland ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
  if command -v wl-copy >/dev/null 2>&1; then
    wl-copy --no-newline
  else
    echo "clip-copy: wl-copy not found (Wayland session)" >&2
    exit 1
  fi
elif [ -n "${DISPLAY:-}" ]; then
  if command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    echo "clip-copy: xclip or xsel not found (DISPLAY=$DISPLAY)" >&2
    exit 1
  fi
elif command -v xclip >/dev/null 2>&1; then
  xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  xsel --clipboard --input
else
  echo "clip-copy: no clipboard tool (pbcopy / wl-copy / xclip / xsel)" >&2
  exit 1
fi
