import { apiRequest, csrfToken } from '../../../../helpers';

export const removeWebhookRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/webhooks/${id}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
