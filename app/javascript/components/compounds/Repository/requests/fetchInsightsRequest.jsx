import { apiRequest } from '../../../../helpers';

export const fetchInsightsRequest = async (id) => {
  return await apiRequest({
    url: `/frontend/repositories/${id}/insights.json`
  });
}
