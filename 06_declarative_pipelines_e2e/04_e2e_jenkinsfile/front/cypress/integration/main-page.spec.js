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
