import { apiRequest, csrfToken } from '../../../helpers';

export const createCompanyRequest = async ({ title, user_uuid }) => {
  return await apiRequest({
    url: '/api/frontend/companies.json',
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ company: { title: title, user_uuid: user_uuid } }),
    },
  });
};
