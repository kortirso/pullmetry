import { apiRequest, csrfToken } from '../../../../helpers';

export const removeNotificationRequest = async (uuid) => {
  return await apiRequest({
    url: `/frontend/notifications/${uuid}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
