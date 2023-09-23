import { apiRequest } from '../../../requests/helpers/apiRequest';

export const repositoryInsightsRequest = async (repositoryUuid) => {
  const result = await apiRequest({
    url: `/api/v1/repositories/${repositoryUuid}/repository_insights.json`,
  });
  return result.insights.data?.attributes?.values || {};
};
