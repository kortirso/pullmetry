import { render } from 'solid-js/web';

import {
  Company,
  CompanyNewModal,
  CompanyEditPrivacy,
  CompanyEditPullRequests,
  CompanyEditInsights,
  CompanyEditNotifications,
  CompanyEditTransfer,
  CompanyEditSettings,
  FeedbackForm,
  Repository,
  RepositoryNewModal,
  ProfilePrivacy,
  ProfileDelete,
  ProfileVacations,
  ProfileSettings,
  WebFlash,
  Wizard
} from './components';

const components = {
  Company,
  CompanyNewModal,
  CompanyEditPrivacy,
  CompanyEditPullRequests,
  CompanyEditInsights,
  CompanyEditNotifications,
  CompanyEditTransfer,
  CompanyEditSettings,
  FeedbackForm,
  Repository,
  RepositoryNewModal,
  ProfilePrivacy,
  ProfileDelete,
  ProfileVacations,
  ProfileSettings,
  WebFlash,
  Wizard
}

document.addEventListener('DOMContentLoaded', () => {
  const mountPoints = document.querySelectorAll('[data-js-component]');
  mountPoints.forEach((mountPoint) => {
    const dataset = mountPoint.dataset;
    const componentName = dataset['jsComponent'];
    const Component = components[componentName];

    if (Component) {
      const props = dataset['props'] ? JSON.parse(dataset['props']) : {};
      const childrenData = dataset['children'] ? JSON.parse(dataset['children']) : null;

      render(() => (
        <Component {...props}>
          {childrenData}
        </Component>
      ), mountPoint);
    }
  });

  // mobile navigation toggle
  const mobileMenuButton = document.querySelector('.mobile-menu-button');
  if (mobileMenuButton) {
    mobileMenuButton.addEventListener('click', () => {
      document.querySelector('.navigation-menu').classList.toggle('hidden');
    });
  }
});

