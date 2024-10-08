import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const createNotificationRequest = async (payload) => {
  return await apiRequest({
    url: '/frontend/notifications.json',
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
