FROM node:20-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=4000

COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

COPY prisma ./prisma
COPY tsconfig*.json nest-cli.json ./
COPY src ./src
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN npx prisma generate && npm run build && chmod +x /docker-entrypoint.sh

EXPOSE 4000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["node", "dist/main.js"]
