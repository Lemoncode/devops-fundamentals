# Integration Test

Create a bash script to initialize the database

```sh
POSTGRES_IMAGE=$1
POSTGRES_PORT=$2

if [[ $(which docker) ]] ; then
    docker run -d -p $POSTGRES_PORT:5432 $POSTGRES_IMAGE
fi

# ./start_db.sh jaimesalas/todos_db 5432
```

Give execution permission `chmod +x start_db.sh`


Run `npm init -y` and modify `package.json`

```diff
{
  "name": "02_integration_test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
-   "test": "echo \"Error: no test specified\" && exit 1"
+   "test": "node index.spec.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}

```

Install the following dependencies

```bash
npm i pg dotenv
```

Create a root `.env` file

```ini
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_NAME=todos_db
DB_PORT=5432
```

Create a programmatic way to connect to database, create `dbConnection.js`

```js
const { Client } = require('pg');

const client = new Client({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

module.exports.client = client;
```

Create `index.spec.js`

```js
require("dotenv").config();

const assert = require("assert");
const { client } = require("./dbConnection");

const expectedElements = [
  {
    id: 12,
    title: "Learn Jenkins",
    completed: false,
    due_date: new Date("2020-12-04T18:37:44.234Z"),
    order: null,
  },
  {
    id: 13,
    title: "Learn GitLab",
    completed: true,
    due_date: new Date("2020-12-04T18:37:44.234Z"),
    order: null,
  },
  {
    id: 21,
    title: "Learn K8s",
    completed: false,
    due_date: new Date("2020-12-04T18:37:44.234Z"),
    order: null,
  },
];

(async () => {
  await client.connect();
  const { rows } = await client.query("SELECT * FROM todos");
  assert.deepStrictEqual(rows, expectedElements);
  await client.end();
})();
```

Let's start the database using our script

```bash
./start_db.sh jaimesalas/todos_db 5432
```

Now we can run `npm test`, nothing prints out to the console, so everything is ok, but this is not a good solution for `CI/CD` environment let's do something different

```diff
{
  "name": "02_integration_test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
+   "pretest": "./start_db.sh jaimesalas/todos_db 5432",
    "test": "node index.spec.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "dotenv": "^8.2.0",
    "pg": "^8.5.1"
  }
}

```

But if we run the tests now, we get an error **TypeError: Cannot destructure property 'rows' of 'undefined' as it is undefined.** What is happening? Well, the database is started but not populated, we can follow different strategies, to solve this problem, but the easiest one is to wait.

Edit `index.spec.js`

```diff
require("dotenv").config();

const assert = require("assert");
const { client } = require("./dbConnection");

const expectedElements = [
  {
    id: 12,
    title: "Learn Jenkins",
    completed: false,
    due_date: new Date("2020-12-04T18:37:44.234Z"),
    order: null,
  },
  {
    id: 13,
    title: "Learn GitLab",
    completed: true,
    due_date: new Date("2020-12-04T18:37:44.234Z"),
    order: null,
  },
  {
    id: 21,
    title: "Learn K8s",
    completed: false,
    due_date: new Date("2020-12-04T18:37:44.234Z"),
    order: null,
  },
];
+
+const delay = (time = 0) => {
+ return new Promise((resolve) => {
+   setTimeout(() => {
+     resolve();
+   }, time);
+ });
+};
+
(async () => {
+ await delay(10_000)
  await client.connect();
  const { rows } = await client.query("SELECT * FROM todos");
  assert.deepStrictEqual(rows, expectedElements);
  await client.end();
})();

```

> EXERCISE: Create `posttest` script that removes the database container.