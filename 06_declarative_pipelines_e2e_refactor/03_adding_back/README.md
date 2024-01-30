# Adding Back

## Moving our hard coding service to the back

Create a new folder `back` and set as root folder

```bash
npm init -y
```

```bash
npm i express cors dotenv
```

Create `index.js`

```js
const express = require("express");
const cors = require("cors");
const app = express();
require("dotenv").config();

app.use(cors());

app.get("/scores", (_, res) => {
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
Dockerfile
```

Create the Dockerfile

```Dockerfile
FROM node:20-alpine

COPY . .

RUN npm ci

CMD ["npm", "start"]
```

## Updating front code

```bash
npm i axios
```

Add `.env`

```
API_URL=http://localhost:4000
```

Update `webpack.config.js`

```bash
npm i dotenv-webpack -D
```

```diff
import HtmlWebpackPlugin from "html-webpack-plugin";
import MiniCssExtractPlugin from "mini-css-extract-plugin";
+import DotEnv from "dotenv-webpack";

export default {
  entry: {
    app: "./src/index.js",
  },
  output: {
    filename: "[name].[chunkhash].js",
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "babel-loader",
      },
      {
        test: /\.css$/,
        exclude: /node_modules/,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
    ],
  },
  devServer: {
    port: 8081,
  },
  plugins: [
    //Generate index.html in /dist => https://github.com/ampedandwired/html-webpack-plugin
    new HtmlWebpackPlugin({
      filename: "index.html", //Name of file in ./dist/
      template: "./src/index.html", //Name of template in ./src
      scriptLoading: "blocking", // Just use the blocking approach (no modern defer or module)
    }),
    new MiniCssExtractPlugin({
      filename: "[name].css",
      chunkFilename: "[id].css",
    }),
+   new DotEnv({
+     path: "./.env",
+   }),
  ],
};

```

Update `index.html`

```diff
<body>
  <h1>Scores App</h1>
+ <div id="container"></div>
</body>
```

Update `index.js`

```js
import axios from "axios";
import * as averageService from "./avarage.service.js";
import "./styles.css";

document.addEventListener("DOMContentLoaded", () => {
  const url = `${process.env.API_URL}/scores`;
  axios
    .get(url)
    .then(({ data }) => {
      const { scores } = data;

      const averageScore = averageService.getAvg(scores);
      const totalScore = averageService.getTotalScore(scores);

      const messageToDisplayAvg = `average score ${averageScore} `;
      const messageToDisplayTotal = `total score ${totalScore}`;

      const spanAvg = document.createElement("span");
      spanAvg.innerHTML = messageToDisplayAvg;
      const spanTotal = document.createElement("span");
      spanTotal.innerHTML = messageToDisplayTotal;

      document.getElementById("container").appendChild(spanAvg);
      document.getElementById("container").appendChild(spanTotal);
    })
    .catch(console.error);
});


```

Update `e2e/cypress.config.js`

```diff
module.exports = defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
    baseUrl: "http://localhost:8081",
+   env: {
+     api_url: "http://localhost:4000/scores",
+   },
  },
});
```

Update `e2e/cypress/e2e/main-page.cy.js`

```js
/// <reference types="Cypress" />

describe("main page", () => {
  it("visit the main page", () => {
    const url = Cypress.env("api_url");
    console.log(url);
    cy.intercept("GET", url).as("getScores");
    cy.visit("/");
    cy.wait("@getScores")
      .its("response")
      .then((res) => {
        expect(res.body.scores).not.null;
      });
    cy.get("body").contains("average score");
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

Update `./front/webpack.config.js` to run on `CI` environments

```diff
plugins: [
    new DotEnv({
        path: './.env',
+       allowEmptyValues: true,
+       systemvars: true,
    }),
],
```

#### Docker Infrastructure

1. Create a Docker network

```bash
docker network create e2e
```

2. Build back image

```bash
docker build -t jaimesalas/e2e-back ./back
```

3. Run backend

```bash
docker run -d --name e2e-back -e PORT=4000 --network e2e jaimesalas/e2e-back
```

5. Update `front/Dockerfile`

```diff
FROM node:20-alpine as build

WORKDIR /opt/build 

+ARG API_URL={{API_URL}}
# ...
```

6. Create `front/entry-point.sh`

- https://unix.stackexchange.com/questions/466999/what-does-exec-do

```bash
#!/bin/sh

sed -i "s|{{API_URL}}|$API_URL|g" /usr/share/nginx/html/app*.js

exec "$@"
```

7. Update `front/Dockerfile`

```diff
# ....
EXPOSE 8081
+
+COPY ./entry-point.sh /
+RUN chmod +x /entry-point.sh 
+ENTRYPOINT ["sh", "/entry-point.sh"]
+
CMD ["nginx", "-g", "daemon off;"]
```

8. Build front for e2e

```bash
docker build -t jaimesalas/e2e-front ./front
```

9. Run front 

```bash
docker run -d --name e2e-front \
 -e API_URL=http://e2e-back:4000 \
 --network e2e \
 jaimesalas/e2e-front
```

10. Run e2e tests

```bash
docker run --rm -e API_URL=http://e2e-back:4000 --network e2e jaimesalas/e2e npm run test:e2e
```

```bash
# on e2e directory
docker run -it -v $PWD/cypress:/app/cypress \
 --network e2e \
 -e "CYPRESS_baseUrl=http://e2e-front:8081" \
 -e "CYPRESS_api_url=http://e2e-back:4000/scores" \
 -v $PWD/cypress.config.js:/app/cypress.config.js \
 jaimesalas/dd-e2e:0.0.1 npm run cypress:run
```