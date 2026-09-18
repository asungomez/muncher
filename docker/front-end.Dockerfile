# syntax=docker/dockerfile:1

# Image that runs the front-end development server. The sources are bind mounted
# at run time, never copied in, so the server sees host edits immediately.

# Its own stage so scripts/front-end-lock.sh can stop here, before the frozen
# install that fails when the lockfile is the thing needing an update.
FROM node:24-bookworm-slim AS yarn

# Declared here so both images this file produces carry it, and
# scripts/run-in-container.sh can discard the untagged ones its rebuilds leave
# behind.
LABEL muncher.image=front-end

RUN corepack enable

# Yarn would otherwise prompt to download the version in "packageManager".
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

WORKDIR /workspace/front-end

FROM yarn

# Only the manifests, so this layer survives a source edit.
COPY front-end/package.json front-end/yarn.lock front-end/.yarnrc.yml ./
RUN yarn install --immutable && yarn cache clean

EXPOSE 5173

# --host because the port is reached from the host, not from inside.
CMD ["yarn", "dev", "--host"]
