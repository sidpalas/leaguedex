FROM node:15-buster-slim

WORKDIR /usr/src/app

RUN apt-get -qy update
RUN apt-get -qy install openssl

RUN yarn global add pm2

COPY package.json .
COPY yarn.lock .

RUN yarn

COPY ./prisma/schema.prisma ./prisma/schema.prisma
RUN yarn prisma generate

COPY . . 

# TODO add build step for typescript

USER node

CMD ["pm2-runtime", "src/index.js"]

