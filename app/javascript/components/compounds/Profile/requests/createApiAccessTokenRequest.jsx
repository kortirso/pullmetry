import { apiRequest, csrfToken } from '../../../../helpers';

export const createApiAccessTokenRequest = async () => {
  return await apiRequest({
    url: '/frontend/api_access_tokens.json',
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
    },
  });
};
