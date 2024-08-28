import { apiRequest } from '../../../../helpers';

export const fetchInsightsRequest = async (companyUuid) => {
  return await apiRequest({
    url: `/api/frontend/companies/${companyUuid}/insights.json`,
  });
};
