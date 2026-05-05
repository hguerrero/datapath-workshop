# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 — Builder
#
# Installs only the TypeScript compiler (avoids the esbuild platform-binary
# issue when the lockfile was generated on a different OS) and compiles src/
# into dist/.
# ─────────────────────────────────────────────────────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

# Install only the compiler — no tsx/esbuild needed for tsc
COPY package.json ./
RUN npm install --ignore-scripts typescript @types/node @types/express @types/cors

COPY tsconfig.json ./
COPY src/ ./src/

RUN node_modules/.bin/tsc

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 — Production
#
# Installs only runtime dependencies (no devDeps, no tsx), copies the compiled
# JS and the static public/ directory, then starts the Express server.
# ─────────────────────────────────────────────────────────────────────────────
FROM node:22-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

# Install production deps only
COPY package.json ./
RUN npm install --omit=dev --ignore-scripts

# Compiled server
COPY --from=builder --chown=node:node /app/dist ./dist

# Static frontend (HTML / CSS / JS)
COPY --chown=node:node public/ ./public/

# Run as non-root
USER node

EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/ping || exit 1

CMD ["node", "dist/server.js"]
