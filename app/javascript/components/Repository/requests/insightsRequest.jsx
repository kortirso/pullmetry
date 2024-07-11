import { apiRequest } from '../../../requests/helpers/apiRequest';

export const insightsRequest = async (repositoryUuid) => {
  const result = await apiRequest({
    url: `/api/frontend/repositories/${repositoryUuid}/insights.json`,
  });
  return result;
};
