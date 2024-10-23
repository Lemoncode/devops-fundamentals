## Construyendo Imágenes

Vamos a empaquetar una aplicación sencilla de NodeJS

```bash
npm init -y
```

```bash
npm i express
```

Nuestro `package.json` debería verse una cosa como esta:

```json
{
  "name": "00_node_app",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1"
  }
}

```

Actualizamos `package.json` con un nuevo script para arrancar la aplicación:

```diff
{
  "name": "00_node_app",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
-   "test": "echo \"Error: no test specified\" && exit 1"
+   "test": "echo \"Error: no test specified\" && exit 1",
+   "start": "node index"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1"
  }
}
```

Creamos en el root _index.js_

```javascript
const express = require('express');

const PORT = 8080;

const app = express();

app.get('/', (req, res) => {
    console.log(req);
    res.send('Hello world\n');
});

app.listen(PORT);

console.log(`Running on port: ${PORT}`);

```

Creamos el _Dockerfile_

```Dockerfile
FROM node:alpine

WORKDIR /opt/app

COPY . .

RUN npm install --only=production

EXPOSE 8080

CMD [ "npm", "start" ]
```

Creamos el _.dockerignore_

```
node_modules
npm-debug.log
```

Ahora podemos lanzar la petición a Docker para que construya la siguiente imagen. 

```bash
docker build -t myapp .
```

La instrucción anterior construirá mi imagen desde el _Dockerfile_ y le pondrá la etiqueta de _myapp_

```bash
docker build -t myapp .
```

```
Sending build context to Docker daemon  20.99kB
Step 1/7 : FROM node:alpine
alpine: Pulling from library/node
cbdbe7a5bc2a: Pull complete 
fb0e3739aee1: Pull complete 
738de7869598: Pull complete 
ffd68be3d86c: Pull complete 
Digest: sha256:7d11fea6d901bfe59999dda0fa3514438628a134d43c27c2eaec43cc8f4b98d5
Status: Downloaded newer image for node:alpine
 ---> 3bf5a7d41d77
Step 2/7 : WORKDIR /opt/app
 ---> Running in a7a4f041c39e
Removing intermediate container a7a4f041c39e
 ---> 563b6ddcf32a
Step 3/7 : COPY index.js .
 ---> 8b3670dc02d9
Step 4/7 : COPY package.json .
 ---> 69639d5bcf80
Step 5/7 : RUN npm install --only=production
 ---> Running in 3265526b1af0
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN 00_build_node_app@1.0.0 No description
npm WARN 00_build_node_app@1.0.0 No repository field.

added 50 packages from 37 contributors and audited 50 packages in 2.344s
found 0 vulnerabilities

Removing intermediate container 3265526b1af0
 ---> 43edac6409b0
Step 6/7 : EXPOSE 8080
 ---> Running in 317180b48a36
Removing intermediate container 317180b48a36
 ---> 2a51d1c6bf42
Step 7/7 : CMD [ "npm", "start" ]
 ---> Running in 9589c169a1ba
Removing intermediate container 9589c169a1ba
 ---> 27bbca364cad
Successfully built 27bbca364cad
Successfully tagged myapp:latest
```

### Comprobando Imágenes

```bash
docker image ls
```

```bash
docker history <image name or id>
```

```bash
docker history myapp
```

```
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
27bbca364cad        7 minutes ago       /bin/sh -c #(nop)  CMD ["npm" "start"]          0B                  
2a51d1c6bf42        7 minutes ago       /bin/sh -c #(nop)  EXPOSE 8080                  0B                  
43edac6409b0        7 minutes ago       /bin/sh -c npm install --only=production        3.22MB              
69639d5bcf80        7 minutes ago       /bin/sh -c #(nop) COPY file:50e7508bab847522…   311B                
8b3670dc02d9        7 minutes ago       /bin/sh -c #(nop) COPY file:3ff315528f0e52c5…   228B                
563b6ddcf32a        7 minutes ago       /bin/sh -c #(nop) WORKDIR /opt/app              0B                  
3bf5a7d41d77        4 days ago          /bin/sh -c #(nop)  CMD ["node"]                 0B                  
<missing>           4 days ago          /bin/sh -c #(nop)  ENTRYPOINT ["docker-entry…   0B                  
<missing>           4 days ago          /bin/sh -c #(nop) COPY file:238737301d473041…   116B                
<missing>           4 days ago          /bin/sh -c apk add --no-cache --virtual .bui…   7.62MB              
<missing>           4 days ago          /bin/sh -c #(nop)  ENV YARN_VERSION=1.22.4      0B                  
<missing>           4 days ago          /bin/sh -c addgroup -g 1000 node     && addu…   104MB               
<missing>           4 days ago          /bin/sh -c #(nop)  ENV NODE_VERSION=14.4.0      0B                  
<missing>           6 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B                  
<missing>           6 weeks ago         /bin/sh -c #(nop) ADD file:b91adb67b670d3a6f…   5.61MB        
```

### Etiquetanso imágenes

```bash
docker tag myapp mynodeapp
docker tag myapp mynodeapp:1
docker tag myapp myorganization/myapp:1
```

### Eliminando Imágenes

```bash
docker rmi mynodeapp:1
```