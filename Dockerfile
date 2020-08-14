FROM alpine:3.9.6 AS base
WORKDIR /usr/src/app
RUN apk add --update nodejs=10.14.2-r0 npm=10.14.2-r0 yarn=1.12.3-r0 --no-cache

FROM base AS builder
COPY package.json yarn.lock .babelrc ./
RUN yarn install
COPY ./src ./src
RUN npm run build

FROM base AS dependencies
COPY package.json yarn.lock .babelrc ./
RUN yarn install --production

FROM base AS release
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
EXPOSE 4000
CMD ["node", "./dist/bin/server.js"]