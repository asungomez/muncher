# syntax=docker/dockerfile:1

# Image that renders the memoria's Mermaid diagrams. Separate from
# memoria.Dockerfile so the image CI builds on every commit does not carry a
# browser: the rendered PDFs are committed, and `make memoria-diagrams` only
# rebuilds the ones whose source changed.

FROM node:24-bookworm-slim

# Lets scripts/run-in-container.sh discard the untagged images its rebuilds
# leave behind.
LABEL muncher.image=diagrams

ENV DEBIAN_FRONTEND=noninteractive

# Debian's chromium, rather than the one Puppeteer downloads: it arrives with
# the shared libraries it needs, which the bundled build does not.
RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
		chromium \
		fonts-liberation \
	&& rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_DOWNLOAD=1
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN npm install --global --no-fund --no-audit \
		@mermaid-js/mermaid-cli@11.17.0 \
		@iconify-json/logos@1.2.14 \
	&& npm cache clean --force

# The renderer's own --iconPacks flag fetches the pack from unpkg at render time,
# at whatever version is current, and draws placeholder glyphs when the fetch
# fails. This is the installed copy instead, passed as a file URL, so a render
# needs no network and the icons cannot change under the committed diagrams.
ENV MUNCHER_ICON_PACK=/usr/local/lib/node_modules/@iconify-json/logos/icons.json

# --no-sandbox because the container runs as root, where Chromium refuses to
# start its sandbox; the file access flag is what lets the page read the pack
# above.
RUN printf '{"args":["--no-sandbox","--disable-dev-shm-usage","--allow-file-access-from-files"]}\n' > /opt/puppeteer.json

# Proves the icons resolve, because nothing downstream can: an unreadable pack
# is reported on the browser console and the renderer still exits 0, writing a
# diagram whose logos are question marks. Rendering the same probe against a
# pack that cannot exist must not produce the same output.
RUN printf 'flowchart TB\n  probe@{ icon: "logos:aws-s3", form: "square", label: "S3" }\n' > /tmp/probe.mmd \
	&& mmdc --input /tmp/probe.mmd --output /tmp/with-icons.svg \
		--iconPacksNamesAndUrls "logos#file://${MUNCHER_ICON_PACK}" \
		--puppeteerConfigFile /opt/puppeteer.json >/dev/null 2>&1 \
	&& mmdc --input /tmp/probe.mmd --output /tmp/without-icons.svg \
		--iconPacksNamesAndUrls "logos#file:///pack-that-does-not-exist.json" \
		--puppeteerConfigFile /opt/puppeteer.json >/dev/null 2>&1 \
	&& if cmp --silent /tmp/with-icons.svg /tmp/without-icons.svg; then \
		echo "the icon pack at ${MUNCHER_ICON_PACK} did not load" >&2; exit 1; \
	fi \
	&& rm /tmp/probe.mmd /tmp/with-icons.svg /tmp/without-icons.svg

WORKDIR /workspace

CMD ["mmdc", "--version"]
