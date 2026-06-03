FROM node:24-alpine

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY scripts/postinstall.mjs ./scripts/postinstall.mjs
COPY packages ./packages
COPY tools ./tools
COPY apps/daemon/package.json ./apps/daemon/package.json
COPY apps/web/package.json ./apps/web/package.json

RUN corepack enable && \
    corepack prepare pnpm@10.33.2 --activate && \
    pnpm install --frozen-lockfile

COPY apps ./apps
COPY skills ./skills
COPY design-systems ./design-systems
COPY craft ./craft
COPY prompt-templates ./prompt-templates
COPY assets ./assets
COPY plugins/_official ./plugins/_official

RUN pnpm --filter @open-design/daemon build

WORKDIR /app/apps/daemon

ENV NODE_ENV=production
ENV OD_BIND_HOST=0.0.0.0
ENV OD_PORT=7456

EXPOSE 7456

CMD ["node", "dist/sidecar/index.js"]
