FROM node:12.7.0-alpine

WORKDIR '/app'

COPY package.json .

RUN yarn

COPY . .

EXPOSE 5001

CMD ["node", "index.js"]
