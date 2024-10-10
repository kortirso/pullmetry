import { apiRequest, csrfToken } from '../../../../helpers';

export const removeWebhookRequest = async (uuid) => {
  return await apiRequest({
    url: `/frontend/webhooks/${uuid}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
