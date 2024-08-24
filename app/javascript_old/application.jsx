// import React from 'react';
// import * as ReactDOMClient from 'react-dom/client';
// import { QueryClient, QueryClientProvider } from 'react-query';

// import {
//   Company,
//   CompanyForm,
//   CompanyConfiguration,
//   FeedbackForm,
//   Repository,
//   RepositoryForm,
//   ProfileConfiguration,
// } from './components';
// import {
//   Flash,
// } from './atoms';

// const components = {
//   Company,
//   CompanyForm,
//   CompanyConfiguration,
//   FeedbackForm,
//   Repository,
//   RepositoryForm,
//   Flash,
//   ProfileConfiguration,
// };
// const queryClient = new QueryClient();

// document.addEventListener('DOMContentLoaded', () => {
//   const mountPoints = document.querySelectorAll('[data-react-component]');
//   mountPoints.forEach((mountPoint) => {
//     const dataset = mountPoint.dataset;
//     const componentName = dataset['reactComponent'];
//     const Component = components[componentName];

//     if (Component) {
//       const props = dataset['props'] ? JSON.parse(dataset['props']) : {};
//       const childrenData = mountPoint.firstChild?.data
//         ? JSON.parse(mountPoint.firstChild?.data)
//         : null;
//       const root = ReactDOMClient.createRoot(mountPoint);
//       root.render(
//         <QueryClientProvider client={queryClient}>
//           <Component {...props}>{childrenData}</Component>
//         </QueryClientProvider>,
//       );
//     }
//   });

//   // mobile navigation toggle
//   const mobileMenuButton = document.querySelector('.mobile-menu-button');
//   if (mobileMenuButton) {
//     mobileMenuButton.addEventListener('click', () => {
//       document.querySelector('.navigation-menu').classList.toggle('hidden');
//     });
//   };
// });
