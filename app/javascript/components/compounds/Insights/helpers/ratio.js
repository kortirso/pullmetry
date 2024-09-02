const REVERSE_ORDER_ATTRIBUTES = [
  // developer insights
  'average_review_seconds',
  'average_merge_seconds',
  'average_open_pr_comments',
  'bad_reviews_count',
  'time_since_last_open_pull_seconds',
  // repository insights
  'average_comment_time',
  'average_review_time',
  'average_merge_time',
];

export const valueSign = (value, insightType) => {
  if (value === 0) return '';
  if (value < 0 && REVERSE_ORDER_ATTRIBUTES.includes(insightType)) return '+';
  if (value > 0 && !REVERSE_ORDER_ATTRIBUTES.includes(insightType)) return '+';

  return '-';
};

export const ratioClass = (value, insightType) => {
  if (value < 0 && !REVERSE_ORDER_ATTRIBUTES.includes(insightType)) return 'text-red-500';
  if (value > 0 && REVERSE_ORDER_ATTRIBUTES.includes(insightType)) return 'text-red-500';

  return 'text-green-500';
};
