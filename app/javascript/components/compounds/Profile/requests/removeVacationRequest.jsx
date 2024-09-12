import { apiRequest, csrfToken } from '../../../../helpers';

export const removeVacationRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/users/vacations/${id}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
