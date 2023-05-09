# Running Cypress

## Adding a basic script

Let's create a simple test with `cypress`, the better way to make this is allow `cypress` to build the scaffolding for us:

```bash
node_modules/cypress/bin/cypress open
```

Remove `./front/cypress/integration/examples`, and create a new file `integration/main-page.spec.js`

```js
/// <reference types="Cypress" />

describe('main page', () => {
    it('visit the main page', () => {
        cy.visit('/');
        cy.get("body").contains('average score'); 
    });
});
```

In order to make that cypress can reach our application, we must update `cypress.json`

```json
{
    "baseUrl": "http://localhost:8081"
}
```

## Running the script

Instead of opening cypress from the terminal, we're going to modify the `package.json`, and then run as a `npm` command.

```diff
# package.json
# ....
"scripts": {
    "start": "webpack serve --mode development",
    "build": "webpack --mode development",
+   "cypress": "cypress open",
    "test": "echo \"Error: no test specified\" && exit 1"
},
# ....
```

* To run our tests, we must open two terminals:
    1. `npm start` -> starts our application on `localhost:8081`
    2. `npm run cypress` -> open cypress terminal
    3. Run our scripts from cypress terminal.

## Automating running Scripts

Right now we have our test that are running on the browser by `cypress`, but the problem with this approach is that must be raised by hand, and does not fit for `CI`. Let's install a `npm` package that helps us:

```bash
npm i start-server-and-test -D
```

Update `package.json` as follows

```diff
# package.json
# ....
"scripts": {
    "start": "webpack serve --mode development",
    "build": "webpack --mode development",
    "cypress": "cypress open",
+   "cy:run": "cypress run",
+   "test:e2e:local": "start-server-and-test start http://localhost:8081 cy:run",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
# ....
```

Now we can run our tests in a CI way `npm run test:e2e:local`
