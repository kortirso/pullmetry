import { apiRequest } from '../../../requests/helpers/apiRequest';

export const insightsRequest = async (repositoryUuid) => {
  const result = await apiRequest({
    url: `/api/v1/repositories/${repositoryUuid}/insights.json`,
  });
  return result.insights.data.map((element) => element.attributes);
};
