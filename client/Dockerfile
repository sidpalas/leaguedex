FROM node:15-buster-slim

WORKDIR /usr/src/app

COPY package.json .
COPY yarn.lock .

RUN yarn

COPY . . 

CMD ["yarn", "start"]