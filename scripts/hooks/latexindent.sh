#!/bin/bash
# latexindent hook. Runs inside the CI image; never on the host.
#
# The image installs latexindent's Perl dependencies, so unlike the previous
# host-based hook this one does not need to degrade gracefully when they are
# missing: if latexindent fails here, it is a real failure.
set -euo pipefail

for file in "$@"; do
	latexindent -s -w "$file"
	# latexindent leaves a numbered backup next to the file it formatted.
	rm -f "${file}.bak" "${file%.tex}.bak"*
done
