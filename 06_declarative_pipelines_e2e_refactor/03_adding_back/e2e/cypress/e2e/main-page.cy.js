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
