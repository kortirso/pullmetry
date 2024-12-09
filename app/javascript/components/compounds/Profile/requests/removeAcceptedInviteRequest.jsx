import { apiRequest, csrfToken } from '../../../../helpers';

export const removeAcceptedInviteRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/companies/users/${id}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
