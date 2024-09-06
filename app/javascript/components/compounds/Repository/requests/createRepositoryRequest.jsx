import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const createRepositoryRequest = async (payload) => {
  console.log(payload);
  return await apiRequest({
    url: '/frontend/repositories.json',
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ repository: objectKeysToSnakeCase(payload) }),
    },
  });
};
