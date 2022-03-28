## Other Dockerfile locations

Empezando desde el código anterior `00_env_variables`

Podemos crear un directorio _dockerfiles_ y crear los siguientes ficheros.

```Dockerfile
FROM node:12-stretch

WORKDIR /opt/app

COPY . .

RUN npm install --only=production

EXPOSE 8080

CMD [ "npm", "start" ]
```

Y _Dockerfile.other_

```Dockerfile
FROM node:latest

WORKDIR /opt/app

COPY . .

RUN npm install --only=production

CMD ["npm", "start"]
```

Ahora para construir nuestras imágenes:

```bash
$ docker build -f dockerfiles/Dockerfile.other -t myotherapp .
```

```bash
$ docker run -d --rm -p 8080:8080 --name myotherapp myotherapp
```
