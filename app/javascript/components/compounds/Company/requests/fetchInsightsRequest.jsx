import { apiRequest } from '../../../../helpers';

export const fetchInsightsRequest = async (companyUuid) => {
  return await apiRequest({
    url: `/frontend/companies/${companyUuid}/insights.json`
  });
}
