import { apiRequest, csrfToken, objectKeysToSnakeCase } from '../../../../helpers';

export const transferCompanyRequest = async (companyUuid, payload) => {
  return await apiRequest({
    url: `/frontend/companies/${companyUuid}/transfer.json`,
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify(objectKeysToSnakeCase(payload)),
    },
  });
};
