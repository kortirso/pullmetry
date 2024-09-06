import { apiRequest } from '../../../../helpers';

export const fetchInsightsRequest = async (repositoryUuid) => {
  return await apiRequest({
    url: `/frontend/repositories/${repositoryUuid}/insights.json`,
  });
};
