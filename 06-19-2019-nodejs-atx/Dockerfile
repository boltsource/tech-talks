FROM node:12

WORKDIR /usr/src/app

COPY package.json ./
COPY yarn.lock ./

COPY dist ./dist

RUN yarn

CMD ["node", "dist/index.js"]