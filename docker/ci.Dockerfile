# syntax=docker/dockerfile:1

# Image that runs every code check for the muncher monorepo.
#
# It carries the whole toolchain — pre-commit, Node.js, Yarn and latexindent —
# so that neither a developer's machine nor CI needs any of them installed. Both
# run their checks through this image, which is what keeps them in step.
#
# Build from the repository root:
#   docker build -f docker/ci.Dockerfile -t muncher-ci:local .

# Node.js is taken from the official image rather than from apt, which does not
# carry the version this project targets.
FROM node:24-bookworm-slim AS node

FROM debian:bookworm-slim

# Lets scripts/run-in-container.sh recognise — and discard — the untagged images
# left behind by its own rebuilds, without touching anything else on the machine.
LABEL muncher.image=ci

ENV DEBIAN_FRONTEND=noninteractive

# git             — pre-commit inspects the repository through it
# python3         — runtime for pre-commit itself
# texlive-extra-utils — provides latexindent
# lib*-perl       — latexindent's Perl dependencies, which it fails without
RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
		ca-certificates \
		git \
		python3 \
		python3-venv \
		perl \
		texlive-extra-utils \
		libfile-homedir-perl \
		liblog-dispatch-perl \
		liblog-log4perl-perl \
		libunicode-linebreak-perl \
		libyaml-tiny-perl \
	&& rm -rf /var/lib/apt/lists/*

# Node.js, npm and corepack. Copied selectively so the rest of /usr/local is
# left alone.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
	&& ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
	&& corepack enable

# pre-commit lives in its own virtual environment: Debian's Python is
# externally managed and refuses installs into the system site-packages.
ENV VIRTUAL_ENV=/opt/pre-commit-venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python3 -m venv "$VIRTUAL_ENV" \
	&& pip install --no-cache-dir pre-commit==4.4.0

# Hook environments are baked into the image so that running a check never
# downloads anything. PRE_COMMIT_HOME is outside /workspace, which is bind
# mounted over at run time.
ENV PRE_COMMIT_HOME=/opt/pre-commit-cache

WORKDIR /workspace

# Front-end dependencies are installed at build time. Only the manifests are
# copied, so this layer is rebuilt only when they change — not on every source
# edit.
COPY front-end/package.json front-end/yarn.lock front-end/.yarnrc.yml ./front-end/
RUN cd front-end \
	&& yarn install --immutable \
	&& yarn cache clean

# Installing the hook environments needs a git repository and the config.
COPY .pre-commit-config.yaml ./
RUN git init -q . \
	&& pre-commit install-hooks \
	&& rm -rf .git

# The repository is bind mounted at run time and is owned by the host user, not
# by root.
RUN git config --system --add safe.directory /workspace

# Yarn resolves the package manager version from the "packageManager" field,
# which would otherwise trigger a download on first use.
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

CMD ["pre-commit", "run", "--all-files"]
