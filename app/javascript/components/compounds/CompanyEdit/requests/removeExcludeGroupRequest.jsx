import { apiRequest, csrfToken } from '../../../../helpers';

export const removeExcludeGroupRequest = async (uuid) => {
  return await apiRequest({
    url: `/frontend/excludes/groups/${uuid}.json`,
    options: {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      }
    }
  });
}
