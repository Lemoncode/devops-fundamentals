# Adding Back

## Moving our hard coding service to the back

Create a new folder `back` and set as root folder

```bash
$ npm init -y
$ npm i express cors dotenv
```

Create `index.js`

```js
const express = require('express');
const cors = require('cors');
const app = express();
require('dotenv').config();

app.use(cors());

app.get('/scores', (_, res) => {
    res.json({ scores: [90, 75, 60, 99, 94, 30] });
});

app.listen(process.env.PORT, () => {
    console.log(`App running on ${process.env.PORT}`);
});
```

Update `package.json`

```diff
# ....
"scripts": {
+   "start": "node .",
    "test": "echo \"Error: no test specified\" && exit 1"
},
# ....
```

Add `.env`

```ini
PORT=4000
```

Create `.dockerignore`

```
node_modules/
```

Create the Dockerfile

```Dockerfile
FROM node:12-buster

COPY . .

RUN npm install

CMD ["npm", "start"]
```

## Updating front code

```bash
$ npm i axios
```

Add `.env`

```
API_URL=http://localhost:4000
```

Update `webpack.config.js`

```bash
$ npm i dotenv-webpack
```

```diff
+const DotEnv = require('dotenv-webpack');
+
module.exports = {
    entry: ['./index.js'],
    output: {
        filename: 'bundle.js'
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel-loader'
            }
        ]
    },
    devServer: {
        port: 8081,
    },
+   plugins: [
+       new DotEnv({
+           path: './.env',
+       }),
+   ],
};
```

Update `index.js`

```js
import { getAvg } from './avarageService';
import axios from 'axios';

document.addEventListener('DOMContentLoaded', () => {
    const url = `${process.env.API_URL}/scores`;
    axios.get(url)
        .then(({ data }) => {
            const { scores } = data;
            const averageScore = getAvg(scores);
            const messageToDisplay = `average score ${averageScore}`;
            document.write(messageToDisplay);
        })
        .catch(console.error);
});
```


Update cypress.json

```diff
{
    "baseUrl": "http://localhost:8081",
+   "env": {
+       "api_url": "http://localhost:4000/scores"
+   }
}
```

Update `./front/cypress/integration/main-page.spec.js`

```js
/// <reference types="cypress" />

describe('main page', () => {
    it('visit the main page', () => {
        const url = Cypress.env('api_url');
        console.log(url);

        cy.server();
        // cy.route('GET', 'http://e2e-back:4000/scores')
        //     .as('scores');
        cy.route('GET', url)
            .as('scores');

        cy.visit('/');
        cy.wait('@scores');

        cy.get('@scores').its('response').then((res) => {
            expect(res.body.scores).not.null;
        })
        
        cy.get("body")
            .contains('average score');
    });
});

```

## Running on local manually

Start back `npm start`

Start front `npm start`

Start cypress `npm run cypress`

Use cypress terminal to run tests.

## Running on Docker

> Exercise: Make at this point run e2e with `Docker` containers.

### Solution

Update `./front/.dockerignore`

```diff
noode_modules/
+.env
```

Update `webpack.config.js` to run on `CI` environments

```diff
plugins: [
    new DotEnv({
        path: './.env',
+       allowEmptyValues: true,
+       systemvars: true,
    }),
],
```

Update `package.json` to make `cypress` consume `env api_url`

```diff
# ...
"scripts": {
    "start": "webpack serve --mode development",
    "build": "webpack --mode development",
    "cypress": "cypress open",
+   "cy:run:env": "cypress run --env api_url=http://e2e-back:4000/scores",
    "cy:run": "cypress run",
    "test:e2e:local": "start-server-and-test start http://localhost:8081 cy:run",
+   "test:e2e": "start-server-and-test start http://localhost:8081 cy:run:env",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
# ...
```

#### Docker Infrastructure

1. Create a Docker network

```bash
$ docker network create e2e
```

2. Build back image

```bash
$ docker build -t jaimesalas/e2e-back ./back
```

3. Run backend

```bash
$ docker run -d --name e2e-back -e PORT=4000 --network e2e jaimesalas/e2e-back
```

4. Build front for e2e

```bash
$ docker build -t jaimesalas/e2e -f ./front/Dockerfile.e2e ./front
```

5. Run e2e tests

```bash
$ docker run --rm -e API_URL=http://e2e-back:4000 --network e2e jaimesalas/e2e npm run test:e2e
```