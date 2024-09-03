import { apiRequest, csrfToken } from '../../../../helpers';

export const createInviteRequest = async (payload) => {
  return await apiRequest({
    url: '/api/frontend/invites.json',
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ invite: payload }),
    },
  });
};
