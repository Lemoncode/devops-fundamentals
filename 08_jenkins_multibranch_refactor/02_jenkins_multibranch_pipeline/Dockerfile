# Base
FROM node:20-alpine AS base
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Build app
FROM base AS build-app
RUN mkdir -p /usr/src/build-app
WORKDIR /usr/src/build-app
COPY ./package*.json ./
RUN npm ci
COPY ./ ./
RUN npm run build

# Release
FROM base AS release
COPY --from=build-app /usr/src/build-app/dist ./

COPY ./package*.json ./
RUN npm ci --only=production

ENV NODE_ENV=production

ENTRYPOINT ["node", "./index.js"]