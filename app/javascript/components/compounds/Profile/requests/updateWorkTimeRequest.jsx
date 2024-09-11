import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const updateWorkTimeRequest = async (payload) => {
  return await apiRequest({
    url: '/frontend/work_times.json',
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
