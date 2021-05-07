FROM node:15-buster-slim

WORKDIR /usr/src/app

RUN apt-get -qy update
RUN apt-get -qy install openssl

COPY package.json .
COPY yarn.lock .

RUN yarn

COPY . . 

# TODO add build step for typescript

CMD ["./bootstrap.sh"]