# Ejecutando los tests en local

Partimos de que ya tenemos preparado la ejecución de la dependencia externa (la base de datos) de forma automatizada. Nuestro objectovo final es ejecutar nuestros tests a través de `Docker Compose`.

`Docker Compose` nos va ayudar a sicncronizar los distintos módulos que necesitamos para ejecutar nuestros tests de integración. Para ello vamos a generar una imagen de Docker cuya única resposnabilidad será la ejecución de los tests de integaración:

`hangman-back/Dockerfile.test-integration`

```Dockerfile
FROM node:alpine3.12

WORKDIR /opt/app

COPY ./src ./src

COPY ./package.json ./package.json

COPY ./package-lock.json ./package-lock.json

COPY ./jest.config.integration.js ./jest.config.integration.js

COPY ./jest.config.specification.js ./jest.config.specification.js

COPY ./tsconfig.json ./tsconfig.json

RUN npm install

CMD [ "npm", "run", "test:integration" ]
```

Con esta imagen preparada podemos crear nuestro `docker compose file` para ejecutar los tests de integración:

`hangman-back/test-integration.yml`

Empezamos por añadir un servicio, que arranque con un contenedor de Postgres sobre el que podamos correr las migraciones de la base de datso

```yml
version: "3.8"

networks:
  integration-tests:
    driver: bridge

services:
  postgres:
    image: postgres:10.4
    container_name: postgres
    volumes:
      - ./database/hangman_database.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - integration-tests
```

A continuación añadimos el servicio encargado de generar la semilla necesaria de la base de datos

```yaml
version: "3.8"

networks:
  integration-tests:
    driver: bridge

services:
  postgres:
    image: postgres:10.4
    container_name: postgres
    volumes:
      - ./database/hangman_database.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - integration-tests
  #..diff..#
  seed:
    container_name: seed
    build:
      context: .
      dockerfile: Dockerfile.migrations
    environment:
      DATABASE_PORT: 5432
      DATABASE_HOST: postgres
      DATABASE_NAME: hangman_db
      DATABASE_USER: postgres
      DATABASE_PASSWORD: postgres
      DATABASE_POOL_MIN: 2
      DATABASE_POOL_MAX: 10
    depends_on: # 1
      - postgres
    command: # 2
      [
        "./wait-for-it.sh",
        "postgres:5432",
        "--strict",
        "--timeout=300",
        "--",
        "./node_modules/knex/bin/cli.js",
        "migrate:latest",
      ]
    networks:
      - integration-tests
    #..diff..#
```

1. Docker Compose, expone `depends_on` este comando hará que el contenedor de `seed` no arranque hasta que el servicio `postgres` este listo.
2. Con Docker Compose podemos ejecutar un comando sobre el contenedor relacionado con nuestro servicio. Notar que aunque el contenedor de postgres este corriendo, no implica que el servidor de base de datos este lsito para ser utilizado, es aquí donde usamos `wait-for-it.sh`, para aseguranos de cuando ejecutemos el ódigo asociado a las migraciones la base de datos este lsita para ser utilizada.

Una vez añadadidas las dependencias, podemos incluir el servicio que corra los tests de integración.

```yaml
version: "3.8"

networks:
  integration-tests:
    driver: bridge

services:
  postgres:
    image: postgres:10.4
    container_name: postgres
    volumes:
      - ./database/hangman_database.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - integration-tests

  seed:
    container_name: seed
    build:
      context: .
      dockerfile: Dockerfile.migrations
    environment:
      DATABASE_PORT: 5432
      DATABASE_HOST: postgres
      DATABASE_NAME: hangman_db
      DATABASE_USER: postgres
      DATABASE_PASSWORD: postgres
      DATABASE_POOL_MIN: 2
      DATABASE_POOL_MAX: 10
    depends_on:
      - postgres
    command:
      [
        "./wait-for-it.sh",
        "postgres:5432",
        "--strict",
        "--timeout=300",
        "--",
        "./node_modules/knex/bin/cli.js",
        "migrate:latest",
      ]
    networks:
      - integration-tests
  #..diff..#
  test-integration:
    container_name: test-integration
    build:
      context: .
      dockerfile: Dockerfile.test-integration
    environment:
      DATABASE_PORT: 5432
      DATABASE_HOST: postgres
      DATABASE_NAME: hangman_db
      DATABASE_USER: postgres
      DATABASE_PASSWORD: postgres
      DATABASE_POOL_MIN: 2
      DATABASE_POOL_MAX: 10
    depends_on:
      postgres:
        condition: service_started
      seed:
        condition: service_completed_successfully
    networks:
      - integration-tests
  #..diff..#
```

Por último vamos a crear un script que corra los tests y limpie el entorno generado por Docker Compose, cuando finalice la ejecución de los mismos:

`hangman-back/run-test.sh`

```bash
echo "start running tests" 

docker compose -f test-integration.yml up -d

echo "tests in progress"

docker wait test-integration

echo "clear resources"

docker compose -f test-integration.yml down --rmi all -v
```