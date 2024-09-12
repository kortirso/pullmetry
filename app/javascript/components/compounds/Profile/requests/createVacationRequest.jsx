import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const createVacationRequest = async (payload) => {
  return await apiRequest({
    url: '/frontend/users/vacations.json',
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      },
      body: JSON.stringify({ user_vacation: objectKeysToSnakeCase(payload) })
    }
  });
}
