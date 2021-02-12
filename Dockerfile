FROM node:latest AS appbuild

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get --yes update
RUN apt-get --yes install apt-utils git optipng build-essential
RUN npm install --global node-gyp

WORKDIR /app

COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json
COPY lib/ /app/lib
RUN npm ci

COPY ./src /app/src
COPY ./.git /app/.git
COPY ./static /app/static
COPY ./assets /app/assets
RUN npm run build:prod

FROM node:latest

WORKDIR /app

COPY lib/config/config.json.dist /app/config/config.json
COPY --from=appbuild /app/dist /usr/share/nginx/html

RUN /bin/chown -R nginx:nginx /usr/share/nginx/html

CMD ["node", "/app/server.js"]