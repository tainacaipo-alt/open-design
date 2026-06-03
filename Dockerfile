FROM node:24-alpine AS builder

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

FROM node:24-alpine

RUN apk add --no-cache poppler-utils tini

WORKDIR /app

COPY --from=builder /app/package.json /app/pnpm-lock.yaml /app/pnpm-workspace.yaml ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/apps/daemon ./apps/daemon
COPY --from=builder /app/skills ./skills
COPY --from=builder /app/design-systems ./design-systems
COPY --from=builder /app/craft ./craft
COPY --from=builder /app/prompt-templates ./prompt-templates
COPY --from=builder /app/assets/frames ./assets/frames
COPY --from=builder /app/assets/community-pets ./assets/community-pets

RUN addgroup -S -g 1001 open-design && \
    adduser -S -D -H -u 1001 -G open-design open-design

USER open-design

ENV NODE_ENV=production
ENV OD_BIND_HOST=0.0.0.0
ENV OD_PORT=7456

EXPOSE 7456

CMD ["/sbin/tini", "--", "node", "apps/daemon/dist/sidecar/index.js"]
