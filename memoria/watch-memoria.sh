#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

build() {
  ./make-memoria.sh
}

echo "[watch] Performing initial build..."
./make-memoria.sh

echo "[watch] Watching 'src' for changes. Press Ctrl-C to stop."

if command -v entr >/dev/null 2>&1; then
  # Use entr (fast and simple)
  while true; do
    find src -type f | entr -d -r bash -c 'echo "[watch] Change detected at '"$(date +"%H:%M:%S")"'"; ./make-memoria.sh'
  done
elif command -v fswatch >/dev/null 2>&1; then
  # Use fswatch (macOS-friendly)
  fswatch -o -r src | while read -r; do
    echo "[watch] Change detected at $(date +"%H:%M:%S")"
    ./make-memoria.sh
  done
else
  # Fallback: lightweight polling using file mtimes
  echo "[watch] Neither 'entr' nor 'fswatch' found; falling back to polling."

  compute_signature() {
    local listing
    # Collect modification time and name for all files in src
    listing="$(find src -type f -exec stat -f "%m %N" {} + 2>/dev/null | sort)"
    if command -v shasum >/dev/null 2>&1; then
      printf "%s" "$listing" | shasum | awk '{print $1}'
    elif command -v md5 >/dev/null 2>&1; then
      printf "%s" "$listing" | md5 -q
    elif command -v md5sum >/dev/null 2>&1; then
      printf "%s" "$listing" | md5sum | awk '{print $1}'
    else
      # Last resort: byte count as a weak signature
      printf "%s" "$listing" | wc -c | tr -d ' \n'
    fi
  }

  prev_sig=""
  while true; do
    curr_sig="$(compute_signature)"
    if [[ "$curr_sig" != "$prev_sig" ]]; then
      echo "[watch] Change detected at $(date +"%H:%M:%S")"
      ./make-memoria.sh
      prev_sig="$curr_sig"
    fi
    sleep 1
  done
fi


