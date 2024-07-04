import { apiRequest } from '../../../requests/helpers/apiRequest';

export const insightsRequest = async (companyUuid) => {
  const result = await apiRequest({
    url: `/api/frontend/companies/${companyUuid}/insights.json`,
  });
  return {
    data: result.insights.data.map((element) => element.attributes),
    ratioType: result.insights.ratio_type
  };
};
