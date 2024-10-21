import { apiRequest, csrfToken } from '../../../../helpers';

export const updateCompanyConfigurationRequest = async (companyUuid, payload) => {
  return await apiRequest({
    url: `/frontend/companies/${companyUuid}/configuration.json`,
    options: {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken()
      },
      body: JSON.stringify({ configuration: payload })
    }
  });
}
