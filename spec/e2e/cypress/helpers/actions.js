const DEFAULT_TIMEOUT = Cypress.config('defaultCommandTimeout');

export const scrollToBySelector = (selector, customTimeout = DEFAULT_TIMEOUT) => {
  return cy.get(selector, { timeout: customTimeout }).scrollIntoView();
};

export const clickBySelector = (
  selector,
  forceClick = false,
  customTimeout = DEFAULT_TIMEOUT,
) => {
  return scrollToBySelector(selector, customTimeout).click({ force: forceClick });
};
