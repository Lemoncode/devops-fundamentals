# Setup

## Escenario

> Integration testing (sometimes called integration and testing, abbreviated I&T) is the phase in software testing in which individual software modules are combined and tested as a group.

Nuestro objetivo es poder incluir los tests de inetgración dentro de nuestro proceso de integarción continua. Como objeto de estudio partiremos de una API, que corre en local dos tipos de test: tests unitarios y tests de integración.

Para los tests unitarios no precesimos de ningún módulo extra, y podemos ejecutarlos en local a través de [Jest](https://jestjs.io/).

```ts
import { setUp, selectWord, WordCategory } from './word-provider.srv';

describe('word-provider.srv', () => {
  test('returns a valid selectedWord', () => {
    // Arrange
    const categories = [
      {
        category: 'clothes',
        words: ['pants', 't-shirt'],
      },
      {
        category: 'sports',
        words: ['football', 'f1'],
      },
    ];

    const categoryLength = categories.length;
    const wordCategories: WordCategory[] = categories.map((c, index) => ({
      categoryId: index,
      categoryLength: c.words.length,
    }));

    setUp(categoryLength, wordCategories);

    // Act
    const selectedWord = selectWord();
    expect(selectedWord.categoryIndex).toBeLessThanOrEqual(categoryLength - 1);
    expect(selectedWord.wordIndex).toBeLessThanOrEqual(categories[selectedWord.categoryIndex].words.length - 1);
  });
});

```

Este tipo de tests, sólo dependen del código y el framework que los ejecuta. Desde un punto de vista de la integración continua, nos plantea un escenario en el que  teniendo inataladas estas dependencias podemos ejecutarlos sin demasiados problemas. Por contra, los tests de integarción implican interacción entre distintos módulos, por lo que necesitaremos que estos módulos estén corriendo en nuestro sistema para poder ejecutarlos. 

En nuestro caso vamos a tener una API que accederá a una base de datos `Postgresql`. Si ecahmos un ojo al código, nos daremos cuenta de que necesitamos una base de datos con las relaciones inicializada, pero no necesariamente `populate`.

```ts
import { db as knex, startConnection } from '../dataAccess';
import { GameEntity, PlayerEntity, WordEntity } from '../entities';
import { gameDALFactory } from './game.dal';

beforeAll(() => {
  startConnection({
    host: process.env.DATABASE_HOST,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    port: +process.env.DATABASE_PORT!,
    database: process.env.DATABASE_NAME,
    dbVersion: process.env.DATABASE_VERSION!,
  });
});

afterAll(async () => {
  await knex.destroy();
});

beforeEach(async () => {
  await knex.from('players').delete();
  await knex.from('words').delete();
  await knex.from('games').delete();
});

describe('game.dal', () => {
  describe('getGames', () => {
    test('returns the games related to a player', async () => {
      // Arrange
      await Promise.all([insertPlayer('joe', 1), insertWord(1, 'car', 'vehicles')]);
      await insertGame(1, 1, 'not_started');
      const gameDAL = gameDALFactory(knex);

      // Act
      const [game] = await gameDAL.getGames(1);
      const { player_id, word_id, game_state } = game;

      // Assert
      expect(player_id).toEqual(1);
      expect(word_id).toEqual(1);
      expect(game_state).toEqual('not_started');
    });
  });
});

const insertPlayer = (name: string, id: number): Promise<PlayerEntity> =>
  knex('players')
    .insert({ id, name }, '*')
    .then(([player]) => player);

const insertWord = (id: number, entry: string, word_category: string): Promise<WordEntity> =>
  knex('words')
    .insert({ id, entry, word_category }, '*')
    .then(([word]) => word);

const insertGame = (player_id: number, word_id: number, game_state: string): Promise<GameEntity> =>
  knex('games')
    .insert({ player_id, word_id, game_state }, '*')
    .then(([game]) => game);

```

## Versionado de la base de datos

Uno de los problemas al que nos vamos a enfrentar cuando realicemos tests de integración, es que los distintos módulos han de estar sincronizados entre si. Las versiones han de concordar.  

En nuestro caso, estamos trabajando con una base de datos, para solucionar este problema, mantendremos el versionado a través de código. Para facilitar, el desarrollo local, vamos a automatizar el proceso de volcado de una base de datos vacia. Para ello partimos del siguiente escenario:

Un script que simplemente crea la base de datos:

`hangman-back/database/hangman_database.sql`

```sql
CREATE DATABASE hangman_db;
```

Y una imagen de Docker que se inicializa con el script anterior:

`hangman-back/database/Dockerfile`

```Dockerfile
FROM postgres:10.4

COPY ./hangman_database.sql /docker-entrypoint-initdb.d
```

Construimos esta imagen

```bash
docker build -t jaimesalas/hangman-db-migration .
```

Las migraciones se ejecutan mediante código, necesitamos un proceso que sea capaz de conectarse con la base de datos y ejecute ese código. Para este fin vamos a crear una nueva imagen de Docker, que contendrá el código necesario para ejecutarlas:

`hangman-back/Dockerfile.migrations`

```Dockerfile
FROM node:14.15.4-buster

WORKDIR /opt/app

COPY ./db/migrations ./db/migrations

COPY ./knexfile.js ./knexfile.js

COPY ./wait-for-it.sh ./wait-for-it.sh
RUN chmod +x wait-for-it.sh

RUN npm init -y 

RUN npm install knex pg dotenv
```

En esta imagen estamos copiando el fichero [wait-for-it.sh](https://github.com/vishnubob/wait-for-it), es script nos permite parar un proceso hasta que obtiene un host o puerto TCP está disponible.

Contruimos esta imagen

```bash
docker build -t jaimesalas/db-migrations -f Dockerfile.migrations .
```

Con las dos imágenes creadas anteriormente podemos escribir el siguiente script que se encargará del volcado de la base de datos:

`hangman-back/database/generate_db_sql.sh`

```bash
#!/bin/bash
set +x 

# 1. Create empty postgres database
# 2. Connect with migrations container and run it
# 3. Dump results 
# 4. Clean resources
CONTAINER=postgres-server
NETWORK=generate-db
DATABASE_NAME=hangman_db

echo removing previous artifacts
rm -f ./hangman_database_init.sql


echo generating database from migrations

# create network
docker network create ${NETWORK}

# Run a generic postgres container from jaimesalas/hangman-db-migration image
docker run \
    -d \
    --name ${CONTAINER} \
    --network ${NETWORK} \
    -e "POSTGRES_USER=postgres" \
    -e "POSTGRES_PASSWORD=postgres" \
    jaimesalas/hangman-db-migration

# Ping postgres before initialize database
HEALTHCHECK=$(docker exec $CONTAINER pg_isready > /dev/null 2>&1; echo $?)
while [ $HEALTHCHECK -ne 0 ]; do
   echo "Waiting for postgres to start..."
   HEALTHCHECK=$(docker exec $CONTAINER pg_isready > /dev/null 2>&1; echo $?)
   sleep 1
done

docker run -d \
  --name migration_container \
  --network ${NETWORK} \
  -e "DATABASE_PORT=5432" \
  -e "DATABASE_HOST=${CONTAINER}" \
  -e "DATABASE_NAME=${DATABASE_NAME}" \
  -e "DATABASE_USER=postgres" \
  -e "DATABASE_PASSWORD=postgres" \
  -e "DATABASE_POOL_MIN=2" \
  -e "DATABASE_POOL_MAX=10" \
  jaimesalas/db-migrations ./node_modules/knex/bin/cli.js migrate:latest

# wait until migrations finish
docker wait migration_container

docker rm migration_container

# dumping database 
docker exec -i $CONTAINER pg_dump --create -U postgres $DATABASE_NAME > ./hangman_database_init.sql 

echo database init script generated

echo cleaning resources

docker rm -fv ${CONTAINER}

docker stop ${CONTAINER} && docker rm ${CONTAINER}

docker network rm ${NETWORK}

```

## Arrancar base de datos en local

Para arrancar la base de datos en local podemos ejecutar el siguiente script:

`hangman-back/database/start_db.sh`

```bash
CONTAINER=$1
PORT=$2
echo starting environment tests running docker ${CONTAINER}

if [ ! "$(docker ps -q -f name=${CONTAINER})" ]; then
  if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER})" ]; then
    # Cleanup
    echo "Deleting previous stopped container ${CONTAINER}"
    docker rm -fv ${CONTAINER}
  fi

  # Run your container
  docker run \
    -d \
    -p ${PORT}:5432 \
    --name ${CONTAINER} \
    -e "POSTGRES_USER=postgres" \
    -e "POSTGRES_PASSWORD=postgres" \
    postgres:10.4

  # Ping postgres before initialize database
  HEALTHCHECK=$(docker exec $CONTAINER pg_isready > /dev/null 2>&1; echo $?)
  while [ $HEALTHCHECK -ne 0 ]; do
    echo "Waiting for postgres to start..."
    HEALTHCHECK=$(docker exec $CONTAINER pg_isready > /dev/null 2>&1; echo $?)
    sleep 1
  done

  # Initialize database
  docker exec -i $CONTAINER psql -U postgres < ./database/hangman_database_init.sql
fi

echo environment up and running

# ./database/start_db.sh postgres 5432

```
