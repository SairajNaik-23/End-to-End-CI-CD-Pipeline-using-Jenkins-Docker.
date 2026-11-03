# Small production image based on Alpine Linux
FROM node:20-alpine

WORKDIR /usr/src/app

# Copy only package files first -> dependency layer is cached between builds
COPY package*.json ./
RUN npm install --omit=dev && npm cache clean --force

COPY server.js .

ENV NODE_ENV=production PORT=3000
EXPOSE 3000

# Docker marks the container "unhealthy" if /health stops answering
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

# Don't run as root
USER node

CMD ["node", "server.js"]
