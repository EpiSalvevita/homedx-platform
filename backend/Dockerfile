FROM node:20-alpine

WORKDIR /app

ENV PORT=4000

COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

COPY prisma ./prisma
COPY tsconfig.json ./
COPY src ./src
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN ./node_modules/.bin/prisma generate && npm run build && chmod +x /docker-entrypoint.sh

ENV NODE_ENV=production

EXPOSE 4000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["node", "dist/main.js"]
