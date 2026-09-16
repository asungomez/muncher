# syntax=docker/dockerfile:1

# Image that runs every code check, for developers and for CI alike.

# Debian's Node.js is older than this project targets.
FROM node:24-bookworm-slim AS node

FROM debian:bookworm-slim

# Lets scripts/run-in-container.sh recognise the untagged images its own
# rebuilds leave behind, and discard only those.
LABEL muncher.image=ci

ENV DEBIAN_FRONTEND=noninteractive

# texlive-extra-utils provides latexindent; the lib*-perl packages are the
# dependencies it fails without. No Python: uv fetches the 3.13 it needs below.
RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
		ca-certificates \
		git \
		perl \
		texlive-extra-utils \
		libfile-homedir-perl \
		liblog-dispatch-perl \
		liblog-log4perl-perl \
		libunicode-linebreak-perl \
		libyaml-tiny-perl \
	&& rm -rf /var/lib/apt/lists/*

# Copied selectively so the rest of /usr/local is left alone.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
	&& ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
	&& corepack enable

# Versions come from api/uv.lock. The groups are named so only the tooling
# lands here, and the environment sits in /opt, which no bind mount hides.
COPY --from=ghcr.io/astral-sh/uv:0.11.23 /uv /usr/local/bin/uv
ENV UV_PROJECT_ENVIRONMENT=/opt/checks-venv
ENV PATH="/opt/checks-venv/bin:$PATH"
WORKDIR /workspace
COPY api/pyproject.toml api/uv.lock ./api/
RUN cd api && uv sync --frozen --only-group checks --only-group lint

# Baked in so a check never downloads anything, and outside the bind mount.
ENV PRE_COMMIT_HOME=/opt/pre-commit-cache

# Only the manifests, so this layer survives a source edit.
COPY front-end/package.json front-end/yarn.lock front-end/.yarnrc.yml ./front-end/
RUN cd front-end \
	&& yarn install --immutable \
	&& yarn cache clean

# install-hooks needs a git repository and the config.
COPY .pre-commit-config.yaml ./
RUN git init -q . \
	&& pre-commit install-hooks \
	&& rm -rf .git

# The bind mounted repository is owned by the host user, not by root.
RUN git config --system --add safe.directory /workspace

# Yarn would otherwise download the version in "packageManager" on first use.
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

CMD ["pre-commit", "run", "--all-files"]
