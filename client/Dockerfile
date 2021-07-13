### install client dependencies
FROM node:15-buster-slim AS base

WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .

RUN yarn

COPY . . 

CMD ["yarn", "start"]


### build static client files
FROM base as builder

RUN yarn build


### copy into nginx base
FROM nginx:1.19 as production

COPY ./nginx.conf /etc/nginx/nginx.conf

COPY --from=builder /usr/src/app/build/ /usr/share/nginx/html


