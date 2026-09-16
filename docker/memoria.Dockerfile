# syntax=docker/dockerfile:1

# Image that builds the memoria. Separate from ci.Dockerfile because TeX Live is
# too large to carry in the image that runs on every commit.

FROM debian:bookworm-slim

# Lets scripts/run-in-container.sh discard the untagged images its rebuilds
# leave behind.
LABEL muncher.image=memoria

ENV DEBIAN_FRONTEND=noninteractive

# cm-super is not optional: without the Type 1 Computer Modern fonts, pdflatex
# falls back to bitmap fonts and the PDF renders blurred.
RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
		texlive-latex-base \
		texlive-latex-recommended \
		texlive-latex-extra \
		texlive-fonts-recommended \
		texlive-lang-spanish \
		cm-super \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["scripts/memoria-build.sh"]
