FROM node:20 AS builder

WORKDIR /app

COPY ./src/flagd-ui/package*.json ./

RUN npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set fetch-retries 5 && \
    npm install

COPY ./src/flagd-ui/. ./

RUN npm run build

FROM node:20-alpine

WORKDIR /app

COPY ./src/flagd-ui/package*.json ./

RUN npm install --omit=dev

COPY --from=builder /app/src/instrumentation.ts ./instrumentation.ts
COPY --from=builder /app/next.config.mjs ./next.config.mjs
COPY --from=builder /app/.next ./.next

EXPOSE 4000

CMD ["npm", "start"]