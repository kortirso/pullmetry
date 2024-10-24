import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const createIgnoreRequest = async (payload) => {
  return await apiRequest({
    url: '/frontend/entities/ignores.json',
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
