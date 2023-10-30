import React from 'react';

const TIME_ATTRIBUTES = ['average_comment_time', 'average_review_time', 'average_merge_time'];
const REVERSE_ORDER_ATTRIBUTES = [
  'average_comment_time',
  'average_review_time',
  'average_merge_time',
];

const SECONDS_IN_MINUTE = 60;
const SECONDS_IN_HOUR = 3_600;
const SECONDS_IN_DAY = 86_400;
const MINUTES_IN_HOUR = 60;
const HOURS_IN_DAY = 24;

export const RepositoryInsights = ({ insightTypes, insights, ratioType }) => {
  const renderRepositoryInsight = (insightType) => (
    <>
      {renderInsight(insights[insightType].value, insightType)}
      {renderInsightRatio(insights[insightType].ratio_value, insightType)}
    </>
  );

  const renderInsight = (value, insightType) => {
    if (value === null) return <></>;
    if (TIME_ATTRIBUTES.includes(insightType)) return toTime(value);

    return value;
  };

  const renderInsightRatio = (value, insightType) => {
    if (ratioType === null) return <></>;
    if (value === null) return <></>;

    return (
      <sup className={`${ratioClass(value, insightType)} ml-1 text-xs`}>
        {valueSign(value)}
        {ratioType === 'change' && TIME_ATTRIBUTES.includes(insightType)
          ? toTime(Math.abs(value))
          : Math.abs(value)}
        {ratioType === 'change' ? '' : '%'}
      </sup>
    );
  };

  const toTime = (value) => {
    if (value < 60) return '1m';

    const minutes = Math.floor((value / SECONDS_IN_MINUTE) % MINUTES_IN_HOUR);
    if (value < SECONDS_IN_HOUR) return `${minutes}m`;

    const hours = Math.floor((value / SECONDS_IN_HOUR) % HOURS_IN_DAY);
    if (value < SECONDS_IN_DAY) return `${hours}h ${minutes}m`;

    return `${Math.floor(value / SECONDS_IN_DAY)}d ${hours}h ${minutes}m`;
  };

  const valueSign = (value, insightType) => {
    if (value === 0) return '';
    if (value < 0 && REVERSE_ORDER_ATTRIBUTES.includes(insightType)) return '+';
    if (value > 0 && !REVERSE_ORDER_ATTRIBUTES.includes(insightType)) return '+';

    return '-';
  };

  const ratioClass = (value, insightType) => {
    if (value < 0 && !REVERSE_ORDER_ATTRIBUTES.includes(insightType)) return 'text-red-500';
    if (value > 0 && REVERSE_ORDER_ATTRIBUTES.includes(insightType)) return 'text-red-500';

    return 'text-green-500';
  };

  return (
    <div className="text-sm md:text-base grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
      <div className="p-4 rounded shadow">
        <h4 className="mb-4">Pull requests</h4>
        <p>Open pull requests - {renderRepositoryInsight('open_pull_requests_count')}</p>
        <p>Commented pull requests - {renderRepositoryInsight('commented_pull_requests_count')}</p>
        <p>Reviewed pull requests - {renderRepositoryInsight('reviewed_pull_requests_count')}</p>
        <p>Merged pull requests - {renderRepositoryInsight('merged_pull_requests_count')}</p>
      </div>
      <div className="p-4 rounded shadow">
        <h4 className="mb-4">Cycle time</h4>
        <p>Avg comment time - {renderRepositoryInsight('average_comment_time')}</p>
        <p>Avg review time - {renderRepositoryInsight('average_review_time')}</p>
        <p>Avg merge time - {renderRepositoryInsight('average_merge_time')}</p>
      </div>
      <div className="p-4 rounded shadow">
        <h4 className="mb-4">Additional stats</h4>
        <p>Comments - {renderRepositoryInsight('comments_count')}</p>
        <p>Avg comments - {renderRepositoryInsight('average_comments_count')}</p>
        <p>Changed LOC - {renderRepositoryInsight('changed_loc')}</p>
        <p>Avg changed LOC - {renderRepositoryInsight('average_changed_loc')}</p>
      </div>
    </div>
  );
};
