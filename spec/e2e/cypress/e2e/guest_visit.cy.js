import { clickBySelector } from '../helpers/actions';

// spec/cypress/e2e/guest_visit.cy.js
describe('Guest visit', () => {
  it('visit main pages', () => {
    // Visit the application under test
    cy.visit('/')
    cy.contains('PullKeeper is open source pull requests analyzer')

    // visit metrics page
    clickBySelector('a[data-test-id="footer-metrics-link"]')
    cy.contains('Review quality metrics')
    cy.contains('Code quality metrics')

    // visit privacy policy page
    clickBySelector('a[data-test-id="footer-privacy-link"]')
    cy.contains('Privacy policy')

    // visit unauthorized page
    cy.visit('/companies')
    cy.contains('You need to sign in')

    // visit unexisting page
    cy.visit('/unexisting', { failOnStatusCode: false })
    cy.contains('Page does not exist')
  })
})
