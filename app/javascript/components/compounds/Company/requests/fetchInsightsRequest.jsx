import { apiRequest } from '../../../../helpers';

export const fetchInsightsRequest = async (companyId) => {
  return await apiRequest({
    url: `/frontend/companies/${companyId}/insights.json`
  });
}
