# Todo App API

## Environment variables

```ini
NODE_ENV=
PORT=
DB_HOST=
DB_USER=
DB_PASSWORD=
DB_PORT=
DB_NAME=
```

- **NODE_ENV** - The application environment, local, development, production...
- **PORT** - The port where tha application is listening
- **DB_HOST** -  Application `host`
- **DB_USER** - The database user
- **DB_PASSWORD** - The password for the database user
- **DB_PORT** - The port where the database is listening
- **DB_NAME** - The database name

## Starting Database Using Docker

First, we build the database server image:

```bash
docker build -t lemoncode/postgres_todo_server -f Dockerfile.todos_db .
```

Now we can start our database by running:

```bash
docker run -d -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust -v todos:/var/lib/postgresql/data --name postgres_todo_server lemoncode/postgres_todo_server
```

We can check that te database was initialised as we expected by running:

```bash
docker exec -it postgres_todo_server psql -U postgres
```

This will open a new `psql` terminal for us. We can inpect the databases by running `/l`. To exit the `psql` terminal `\q`.

## Connecting to Database

To connect to the database in our local development enviroment, we must create a new `.env` file on root, that looks like follows:

```ini
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=postgres
DB_PORT=5432
DB_NAME=todos_db
```

To apply migartions run:

```bash
npx knex migrate:latest
```

If we want to have some data we can run:

```bash
npx knex seed:run
```

## Unit Tests

```bash
npm test
```

## Integration Tests

To run the integration tests locally we need the database up and running:

```bash
docker run -d -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust -v todos:/var/lib/postgresql/data --name postgres_todo_server lemoncode/postgres_todo_server
```

```bash
npm run test:e2e
```

## Running the Application with Locally with Docker

```bash
docker build -t lemoncode/todo-app .
```

```bash
docker network create lemoncode
```

```bash
docker run -d -v todos:/var/lib/postgresql/data \
 --network lemoncode \
 --name pg-todo-server \
 lemoncode/postgres_todo_server
```

```bash
docker run -d --rm -p 3000:3000 \
  --network lemoncode \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DB_HOST=pg-todo-server \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=todos_db \
  lemoncode/todo-app
```

```bash
curl localhost:3000/api/
```