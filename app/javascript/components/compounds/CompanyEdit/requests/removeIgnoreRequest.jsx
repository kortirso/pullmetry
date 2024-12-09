import { apiRequest, csrfToken } from '../../../../helpers';

export const removeIgnoreRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/entities/ignores/${id}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
