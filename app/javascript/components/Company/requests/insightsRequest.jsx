import { apiRequest } from '../../../requests/helpers/apiRequest';

export const insightsRequest = async (companyUuid) => {
  const result = await apiRequest({
    url: `/api/frontend/companies/${companyUuid}/insights.json`,
  });
  return result;
};
