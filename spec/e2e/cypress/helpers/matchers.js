import { scrollToBySelector } from './actions';

const DEFAULT_TIMEOUT = Cypress.config('defaultCommandTimeout');

export const isVisibleBySelector = (selector, customTimeout = DEFAULT_TIMEOUT) => {
  return scrollToBySelector(selector, customTimeout).should('be.visible');
};

export const doesNotExistBySelector = (selector, customTimeout = DEFAULT_TIMEOUT) => {
  return cy.get(selector, { timeout: customTimeout }).should('not.exist');
};

export const doesNotExistByText = (text, customTimeout = DEFAULT_TIMEOUT) => {
  return cy.contains(text, { timeout: customTimeout }).should('not.exist');
};
