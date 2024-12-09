import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const transferCompanyRequest = async (companyId, payload) => {
  return await apiRequest({
    url: `/frontend/companies/${companyId}/transfer.json`,
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      },
      body: JSON.stringify(objectKeysToSnakeCase(payload))
    }
  });
}
