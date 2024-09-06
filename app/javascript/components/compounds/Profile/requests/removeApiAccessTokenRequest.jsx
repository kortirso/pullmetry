import { apiRequest, csrfToken } from '../../../../helpers';

export const removeApiAccessTokenRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/api_access_tokens/${id}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      }
    },
  });
};
