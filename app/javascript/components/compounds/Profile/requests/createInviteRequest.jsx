import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const createInviteRequest = async (payload) => {
  return await apiRequest({
    url: '/frontend/invites.json',
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      },
      body: JSON.stringify(objectKeysToSnakeCase(payload))
    }
  });
}