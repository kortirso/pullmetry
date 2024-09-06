import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const updateProfileRequest = async (payload) => {
  return await apiRequest({
    url: '/frontend/profile.json',
    options: {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ user: objectKeysToSnakeCase(payload) }),
    },
  });
};
