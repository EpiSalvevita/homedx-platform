FROM node:20-alpine

WORKDIR /app

ENV PORT=4000

COPY package.json package-lock.json ./
RUN npm ci --legacy-peer-deps

COPY prisma ./prisma
COPY tsconfig.json ./
COPY src ./src
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN ./node_modules/.bin/prisma generate && npm run build && chmod 755 /docker-entrypoint.sh
ENV NODE_ENV=production

RUN apk add --no-cache wget && chown -R node:node /app

USER node

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://127.0.0.1:4000/gg-homedx-json/gg-api/v1/get-be-status-flags || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["node", "dist/src/main.js"]
