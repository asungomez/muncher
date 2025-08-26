#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  RESET='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  CYAN=''
  RESET=''
fi

build() {
  if ./make-memoria.sh; then
    echo -e "${GREEN}[watch] Build succeeded${RESET}"
  else
    echo -e "${RED}[watch] Build failed (non-interactive). Waiting for next change...${RESET}"
  fi
}

echo -e "${BLUE}[watch] Performing initial build...${RESET}"
build

echo -e "${CYAN}[watch] Watching 'src' for changes. Press Ctrl-C to stop.${RESET}"

if command -v entr >/dev/null 2>&1; then
  # Use entr (fast and simple)
  while true; do
    find src -type f | entr -d -r bash -c 'echo -e "\033[0;33m[watch] Change detected at '"$(date +"%H:%M:%S")"'\033[0m"; ./make-memoria.sh || true'
  done
elif command -v fswatch >/dev/null 2>&1; then
  # Use fswatch (macOS-friendly)
  fswatch -o -r src | while read -r; do
    echo -e "${YELLOW}[watch] Change detected at $(date +"%H:%M:%S")${RESET}"
    ./make-memoria.sh || true
  done
else
  # Fallback: lightweight polling using file mtimes
  echo -e "${YELLOW}[watch] Neither 'entr' nor 'fswatch' found; falling back to polling.${RESET}"

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
      echo -e "${YELLOW}[watch] Change detected at $(date +"%H:%M:%S")${RESET}"
      ./make-memoria.sh || true
      prev_sig="$curr_sig"
    fi
    sleep 1
  done
fi


