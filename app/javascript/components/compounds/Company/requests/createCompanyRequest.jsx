import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const createCompanyRequest = async (payload) => {
  return await apiRequest({
    url: '/frontend/companies.json',
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ company: objectKeysToSnakeCase(payload) }),
    },
  });
};
