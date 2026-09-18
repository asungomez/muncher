#!/bin/bash
# Renders one Mermaid diagram of the memoria to the PDF beside it, which is what
# the figures in memoria/src/sections include. Invoke through
# `make memoria-diagrams`, which renders only the sources that changed.
set -euo pipefail

if [ -z "${MUNCHER_IN_CONTAINER:-}" ]; then
	echo "❌ this script runs inside the diagrams container; use 'make memoria-diagrams'" >&2
	exit 1
fi

SOURCE="${1:?usage: memoria-diagrams.sh <diagram.mmd>}"

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$SOURCE" ]; then
	echo "❌ ${SOURCE} not found" >&2
	exit 1
fi

# The renderer treats an unreadable pack as a console message and still exits 0,
# so the diagram would land in the memoria with question marks where the logos
# belong. The image's build proves the pack loads; this proves it is still there.
if [ ! -r "${MUNCHER_ICON_PACK:?the diagrams image must set MUNCHER_ICON_PACK}" ]; then
	echo "❌ icon pack not readable at ${MUNCHER_ICON_PACK}" >&2
	exit 1
fi

echo "🖉  Rendering ${SOURCE}..."

# --pdfFit crops the page to the diagram, so the figure carries no margin of its
# own and \includegraphics scales it to the width the section asks for.
mmdc \
	--input "$SOURCE" \
	--output "${SOURCE%.mmd}.pdf" \
	--pdfFit \
	--iconPacksNamesAndUrls "logos#file://${MUNCHER_ICON_PACK}" \
	--puppeteerConfigFile /opt/puppeteer.json
