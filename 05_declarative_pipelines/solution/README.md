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
DB_VERSION=
```

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
