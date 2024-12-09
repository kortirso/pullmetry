import { apiRequest, csrfToken } from '../../../../helpers';

export const removeExcludeGroupRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/excludes/groups/${id}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
