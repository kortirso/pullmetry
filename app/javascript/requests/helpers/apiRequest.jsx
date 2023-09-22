export const apiRequest = ({ url, options }) =>
  fetch(url, options)
    .then((response) => response.json())
    .then((data) => data);
