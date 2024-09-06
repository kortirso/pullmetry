import { apiRequest, csrfToken } from '../../../../helpers';

export const createFeedbackRequest = async (payload) => {
  return await apiRequest({
    url: '/frontend/feedback.json',
    options: {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': csrfToken(),
      },
      body: JSON.stringify({ feedback: payload }),
    },
  })
};
