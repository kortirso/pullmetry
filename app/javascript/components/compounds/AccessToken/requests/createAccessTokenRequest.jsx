import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const createAccessTokenRequest = async (payload) => {
  return await apiRequest({
    url: `/frontend/${payload.tokenable}/${payload.uuid}/access_tokens`,
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      },
      body: JSON.stringify({ access_token: objectKeysToSnakeCase(payload.payload) })
    }
  });
}
