# syntax=docker/dockerfile:1

# Image that builds the memoria.
#
# Kept separate from docker/ci.Dockerfile: the checks and the document build are
# different toolchains, and TeX Live is large enough that pulling it into the
# image used on every commit would be wasteful.
#
# Build from the repository root:
#   docker build -f docker/memoria.Dockerfile -t muncher-memoria:local .

FROM debian:bookworm-slim

# Lets scripts/run-in-container.sh recognise — and discard — the untagged images
# left behind by its own rebuilds.
LABEL muncher.image=memoria

ENV DEBIAN_FRONTEND=noninteractive

# texlive-latex-base          — pdflatex itself
# texlive-latex-recommended   — caption/subcaption, tools
# texlive-latex-extra         — enumitem and other add-ons used by the preamble
# texlive-fonts-recommended   — the fonts and dingbats the document selects
# texlive-lang-spanish        — babel's Spanish hyphenation patterns
# cm-super                    — Type 1 versions of the T1-encoded Computer
#                               Modern fonts. Without it pdflatex generates
#                               bitmap (.pk) fonts instead, and the text in the
#                               resulting PDF renders blurred.
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
