## Running Migrations

To avoid install Knex globally we can run `cli` from `node_modules`

```ini
DATABASE_PORT=
DATABASE_HOST=
DATABASE_USER=
DATABASE_PASSWORD=
DATABASE_NAME=
DATABASE_POOL_MIN=
DATABASE_POOL_MAX=
PORT=
```

> Migrations Gist: https://gist.github.com/NigelEarle/70db130cc040cc2868555b29a0278261

## Running Tests


```bash
$ docker-compose -f test-integration.yml up
```

```bash
$ docker-compose -f test-integration.yml down --rmi all -v
```