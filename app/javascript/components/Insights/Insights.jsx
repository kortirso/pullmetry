import React, { useState, useMemo } from 'react';

import { Arrow } from '../../assets';

const SHORT_INSIGHT_NAMES = {
  required_reviews_count: 'Req reviews',
  comments_count: 'Comments',
  conventional_comments_count: 'Good comments',
  reviews_count: 'Reviews',
  bad_reviews_count: 'Bad reviews',
  review_involving: 'Involving',
  average_review_seconds: 'Review time',
  reviewed_loc: 'Rev LOC',
  average_reviewed_loc: 'Avg rev LOC',
  open_pull_requests_count: 'Open pulls',
  average_merge_seconds: 'Merge time',
  average_open_pr_comments: 'Avg commenting',
  changed_loc: 'Changed LOC',
  average_changed_loc: 'Avg changed LOC',
  time_since_last_open_pull_seconds: 'Time since last pull',
};

const INSIGHT_TOOLTIPS = {
  required_reviews_count: 'Required reviews',
  comments_count: 'Total comments',
  conventional_comments_count: 'Good comments',
  reviews_count: 'Total reviews',
  bad_reviews_count: 'Total bad reviews',
  review_involving: 'Review involving',
  average_review_seconds: 'Avg review time',
  reviewed_loc: 'Reviewed LOC',
  average_reviewed_loc: 'Avg reviewed LOC',
  open_pull_requests_count: 'Open pulls',
  average_merge_seconds: 'Avg merge time',
  average_open_pr_comments: 'Avg received comments',
  changed_loc: 'Changed LOC',
  average_changed_loc: 'Avg changed LOC',
  time_since_last_open_pull_seconds: 'Time since last pull',
};

const TIME_ATTRIBUTES = ['average_review_seconds', 'average_merge_seconds', 'time_since_last_open_pull_seconds'];
const REVERSE_ORDER_ATTRIBUTES = [
  'average_review_seconds',
  'average_merge_seconds',
  'average_open_pr_comments',
  'bad_reviews_count',
  'time_since_last_open_pull_seconds',
];
const PERCENTILE_ATTRIBUTES = ['review_involving'];

const SECONDS_IN_MINUTE = 60;
const SECONDS_IN_HOUR = 3_600;
const SECONDS_IN_DAY = 86_400;
const MINUTES_IN_HOUR = 60;
const HOURS_IN_DAY = 24;

export const Insights = ({ insightTypes, entities, ratioType, mainAttribute }) => {
  const [pageState, setPageState] = useState({
    sortBy: insightTypes.includes(mainAttribute) ? mainAttribute : insightTypes[0],
    sortDirection: 'desc'
  });

  const changeSorting = (insightType) => {
    if (pageState.sortBy === insightType) setPageState({ ...pageState, sortDirection: (pageState.sortDirection === 'asc' ? 'desc' : 'asc') })
    else setPageState({ sortBy: insightType, sortDirection: 'desc' })
  }

  const sortedEntities = useMemo(() => {
    return entities
      .sort((a, b) => {
        if (pageState.sortDirection === 'asc' && !REVERSE_ORDER_ATTRIBUTES.includes(pageState.sortBy) || pageState.sortDirection === 'desc' && REVERSE_ORDER_ATTRIBUTES.includes(pageState.sortBy)) {
          return a.values[pageState.sortBy].value < b.values[pageState.sortBy].value ? -1 : 1;
        } else {
          return a.values[pageState.sortBy].value < b.values[pageState.sortBy].value ? 1 : -1;
        }
      });
  }, [pageState, entities]);

  const renderEntity = (data) => {
    return (
      <tr key={data.entity.login}>
        <td>
          <a href={data.entity.html_url} target="_blank" rel="noopener noreferrer" className="inline-block w-6 h-6">
            <img src={data.entity.avatar_url} alt="entity" className="w-6 h-6" />
          </a>
        </td>
        <td>{data.entity.login}</td>
        {insightTypes.map((insightType) => {
          if (data.values[insightType].value === null)
            return <td key={`data-${data.entity.login}-${insightType}`}>-</td>;

          return (
            <td key={`data-${data.entity.login}-${insightType}`}>
              <span className="whitespace-nowrap">
                {renderInsight(data.values[insightType].value, insightType)}
                {renderInsightRatio(data.values[insightType].ratio_value, insightType)}
              </span>
            </td>
          );
        })}
      </tr>
    );
  };

  const renderInsight = (value, insightType) => {
    if (value === null) return <></>;
    if (TIME_ATTRIBUTES.includes(insightType)) return toTime(value);
    if (PERCENTILE_ATTRIBUTES.includes(insightType)) return `${value}%`;

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
    <table className="table" cellSpacing="0">
      <thead>
        <tr>
          <th></th>
          <th>Developer</th>
          {insightTypes.map((insightType) => (
            <th
              className="cursor-pointer tooltip"
              onClick={() => changeSorting(insightType)}
              key={`header-${insightType}`}
            >
              <div className="flex flex-row items-center">
                <span className="whitespace-nowrap">{SHORT_INSIGHT_NAMES[insightType]}</span>
                {pageState.sortBy === insightType ? (
                  <span className="ml-2">
                    <Arrow active rotated={pageState.sortDirection === 'asc'} />
                  </span>
                ) : (
                  <span className="ml-2">
                    <Arrow rotated={false} />
                  </span>
                )}
              </div>
              <span className="tooltiptext">{INSIGHT_TOOLTIPS[insightType]}</span>
            </th>
          ))}
        </tr>
      </thead>
      <tbody>{sortedEntities.map((data) => renderEntity(data))}</tbody>
    </table>
  );
};
