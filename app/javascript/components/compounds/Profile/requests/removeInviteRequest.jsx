import { apiRequest, csrfToken } from '../../../../helpers';

export const removeInviteRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/invites/${id}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
