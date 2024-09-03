import { apiRequest, csrfToken } from '../../../../helpers';

export const removeInviteRequest = async (uuid) => {
  return await apiRequest({
    url: `/api/frontend/invites/${uuid}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      }
    },
  });
};
