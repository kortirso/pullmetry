import { apiRequest } from '../../../../helpers';

export const fetchRepositoryInsightsRequest = async (repositoryUuid) => {
  return await apiRequest({
    url: `/api/frontend/repositories/${repositoryUuid}/repository_insights.json`,
  });
};
