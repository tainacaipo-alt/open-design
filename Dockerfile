FROM node:24-alpine

RUN apk add --no-cache python3 make g++

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY scripts/postinstall.mjs ./scripts/postinstall.mjs
COPY packages ./packages
COPY tools ./tools
COPY apps ./apps
COPY skills ./skills
COPY design-systems ./design-systems
COPY craft ./craft
COPY prompt-templates ./prompt-templates
COPY assets ./assets
COPY plugins/_official ./plugins/_official

RUN corepack enable && \
    corepack prepare pnpm@10.33.2 --activate && \
    pnpm install --frozen-lockfile && \
    pnpm --filter @open-design/daemon build

WORKDIR /app/apps/daemon

ENV NODE_ENV=production
ENV OD_BIND_HOST=0.0.0.0
ENV OD_PORT=7456

EXPOSE 7456

CMD ["node", "dist/sidecar/index.js"]
