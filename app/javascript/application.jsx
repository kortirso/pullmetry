import React from 'react';
import * as ReactDOMClient from 'react-dom/client';
import { QueryClient, QueryClientProvider } from 'react-query';

import { Company, CompanyForm, FeedbackForm, Repository, Dropdown, ExcludeRules, Flash } from './components';

const components = {
  Company,
  CompanyForm,
  FeedbackForm,
  Repository,
  Dropdown,
  ExcludeRules,
  Flash,
};
const queryClient = new QueryClient();

document.addEventListener('DOMContentLoaded', () => {
  const mountPoints = document.querySelectorAll('[data-react-component]');
  mountPoints.forEach((mountPoint) => {
    const dataset = mountPoint.dataset;
    const componentName = dataset['reactComponent'];
    const Component = components[componentName];

    if (Component) {
      const props = dataset['props'] ? JSON.parse(dataset['props']) : {};
      const childrenData = mountPoint.firstChild?.data
        ? JSON.parse(mountPoint.firstChild?.data)
        : null;
      const root = ReactDOMClient.createRoot(mountPoint);
      root.render(
        <QueryClientProvider client={queryClient}>
          <Component {...props}>{childrenData}</Component>
        </QueryClientProvider>,
      );
    }
  });
});
