import { apiRequest } from '../../../../helpers';

export const fetchRepositoryInsightsRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/repositories/${id}/repository_insights.json`
  });
}
