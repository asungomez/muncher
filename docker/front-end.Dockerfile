# syntax=docker/dockerfile:1

# Image that runs the front-end development server.
#
# It is a snapshot of the runtime and the dependencies only. The source code is
# never copied in: it is bind mounted from the host at run time, so editing a
# file on the host is immediately visible to the server running inside.
#
# Build from the repository root:
#   docker build -f docker/front-end.Dockerfile -t muncher-front-end:local .

FROM node:24-bookworm-slim

# Lets scripts/run-in-container.sh recognise — and discard — the untagged images
# left behind by its own rebuilds.
LABEL muncher.image=front-end

RUN corepack enable

# Yarn resolves the package manager version from the "packageManager" field,
# which would otherwise trigger a prompt on first use.
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

WORKDIR /workspace/front-end

# Dependencies are installed at build time from the manifests alone, so this
# layer is rebuilt only when they change — not on every source edit.
COPY front-end/package.json front-end/yarn.lock front-end/.yarnrc.yml ./
RUN yarn install --immutable && yarn cache clean

# Vite must listen on every interface: the port is reached from the host, not
# from inside the container.
EXPOSE 5173

CMD ["yarn", "dev", "--host"]
