#!/bin/bash
# Rebuilds the memoria whenever anything under memoria/src changes.
#
# Runs inside the image built from docker/memoria.Dockerfile. Invoke it through
# `make memoria-watch`, which takes care of the container. Stop it with Ctrl-C.
set -uo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	echo "❌ this script runs inside the memoria container; use 'make memoria-watch'" >&2
	exit 1
fi

# Derived from the script's own location: the memoria image carries TeX Live, not
# git, so the repository root cannot be asked for.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT/memoria"

# Only define colors if stdout is a terminal
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
	if "$REPO_ROOT/scripts/memoria-build.sh" >/dev/null; then
		echo -e "${GREEN}[watch] Build succeeded${RESET}"
	else
		echo -e "${RED}[watch] Build failed. Waiting for next change...${RESET}"
	fi
}

# Changes are made on the host and reach the container through a bind mount,
# which does not deliver inotify events reliably. Watching by polling the
# modification times is therefore the only dependable option here, and it is
# cheap enough for a source tree of this size.
compute_signature() {
	find src -type f -printf '%T@ %p\n' | sort | md5sum | cut -d' ' -f1
}

echo -e "${BLUE}[watch] Performing initial build...${RESET}"
build

echo -e "${CYAN}[watch] Watching 'src' for changes. Press Ctrl-C to stop.${RESET}"

prev_sig="$(compute_signature)"
while true; do
	sleep 1
	curr_sig="$(compute_signature)"
	if [[ "$curr_sig" != "$prev_sig" ]]; then
		echo -e "${YELLOW}[watch] Change detected at $(date +"%H:%M:%S")${RESET}"
		build
		prev_sig="$(compute_signature)"
	fi
done
