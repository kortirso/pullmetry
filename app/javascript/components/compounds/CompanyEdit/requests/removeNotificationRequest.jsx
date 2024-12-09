import { apiRequest, csrfToken } from '../../../../helpers';

export const removeNotificationRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/notifications/${id}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
