FROM node:20-alpine as build

WORKDIR /opt/build 

COPY ./src ./src

COPY .babelrc .

COPY *.json ./

COPY webpack.config.js .

RUN npm ci

RUN npm run build

FROM nginx:alpine as app 

COPY nginx.conf /etc/nginx/nginx.conf 

WORKDIR /usr/share/nginx/html 
COPY --from=build /opt/build/dist/ .

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]