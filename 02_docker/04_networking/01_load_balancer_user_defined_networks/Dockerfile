FROM node:alpine

WORKDIR /opt/app

COPY index.js .
COPY package.json .

RUN npm install --only=production

EXPOSE 8080

CMD [ "npm", "start" ]