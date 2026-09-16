# syntax=docker/dockerfile:1

# Image that runs the front-end development server. The sources are bind mounted
# at run time, never copied in, so the server sees host edits immediately.

FROM node:24-bookworm-slim

# Lets scripts/run-in-container.sh discard the untagged images its rebuilds
# leave behind.
LABEL muncher.image=front-end

RUN corepack enable

# Yarn would otherwise prompt to download the version in "packageManager".
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

WORKDIR /workspace/front-end

# Only the manifests, so this layer survives a source edit.
COPY front-end/package.json front-end/yarn.lock front-end/.yarnrc.yml ./
RUN yarn install --immutable && yarn cache clean

EXPOSE 5173

# --host because the port is reached from the host, not from inside.
CMD ["yarn", "dev", "--host"]
