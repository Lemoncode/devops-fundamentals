/// <reference types="Cypress" />

describe('main page', () => {
  it('visit the main page', () => {
    cy.visit('/');
    cy.get('body').contains('average score');
  })
})