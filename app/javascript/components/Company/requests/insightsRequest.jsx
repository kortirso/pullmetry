import { apiRequest } from '../../../requests/helpers/apiRequest';

export const insightsRequest = async (companyUuid) => {
  const result = await apiRequest({
    url: `/api/v1/companies/${companyUuid}/insights.json`,
  });
  return result.insights.data.map((element) => element.attributes);
};
