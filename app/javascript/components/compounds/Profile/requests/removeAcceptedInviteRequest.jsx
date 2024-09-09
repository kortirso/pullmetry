import { apiRequest, csrfToken } from '../../../../helpers';

export const removeAcceptedInviteRequest = async (uuid) => {
  return await apiRequest({
    url: `/frontend/companies/users/${uuid}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
