import { apiRequest, csrfToken } from '../../../../helpers';

export const removeIgnoreRequest = async (uuid) => {
  return await apiRequest({
    url: `/frontend/entities/ignores/${uuid}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
