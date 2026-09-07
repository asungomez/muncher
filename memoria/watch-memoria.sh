#!/bin/bash
# Rebuilds the memoria whenever anything under memoria/src changes.
#
# TeX Live lives in the image built from docker/memoria.Dockerfile, not on the
# developer's machine. When run on the host this script does nothing but
# delegate; the body below executes inside the container.
# See agents/local-development/containerized-development.md.
#
# Stop it with Ctrl-C.
set -uo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	REPO_ROOT="$(git rev-parse --show-toplevel)"
	exec "$REPO_ROOT/scripts/run-in-container.sh" --image memoria ./watch-memoria.sh "$@"
fi

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
	if ./make-memoria.sh >/dev/null; then
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
