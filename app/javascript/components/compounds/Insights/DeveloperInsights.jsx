import { Show, For, Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Arrow } from '../../../assets';
import { toFormattedTime } from '../../../helpers';

import { valueSign, ratioClass } from './helpers/ratio';

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

export const DeveloperInsights = (props) => {
  // eslint-disable-next-line solid/reactivity
  const entities = props.entities;
  // eslint-disable-next-line solid/reactivity
  const defaultSortBy = props.insightTypes.includes(props.mainAttribute) ? props.mainAttribute : props.insightTypes[0];

  const sortEntities = (sortBy, sortDirection) => {
    const sorting = sortDirection === 'asc' && !REVERSE_ORDER_ATTRIBUTES.includes(sortBy) || sortDirection === 'desc' && REVERSE_ORDER_ATTRIBUTES.includes(sortBy)
    return entities.slice().sort((a, b) => {
      let compare = a.values[sortBy].value < b.values[sortBy].value;

      if (sorting && compare || !sorting && !compare) return -1;
      return 1;
    });
  };

  const [pageState, setPageState] = createStore({
    sortBy: defaultSortBy,
    sortDirection: 'desc',
    sortedEntities: sortEntities(defaultSortBy, 'desc')
  });

  const changeSorting = (insightType) => {
    if (pageState.sortBy === insightType) {
      const sortDirection = pageState.sortDirection === 'asc' ? 'desc' : 'asc';
      setPageState({
        sortDirection: sortDirection,
        sortedEntities: sortEntities(pageState.sortBy, sortDirection)
      });
    } else {
      setPageState({
        sortBy: insightType,
        sortDirection: 'desc',
        sortedEntities: sortEntities(insightType, 'desc')
      });
    };
  };

  return (
    <table class="table" cellSpacing="0">
      <thead>
        <tr>
          <th />
          <th>Developer</th>
          <For each={props.insightTypes}>
            {(insightType) =>
              <th
                class="cursor-pointer tooltip"
                onClick={() => changeSorting(insightType)}
              >
                <div class="flex flex-row items-center">
                  <span class="whitespace-nowrap">{SHORT_INSIGHT_NAMES[insightType]}</span>
                  {pageState.sortBy === insightType ? (
                    <span class="ml-2">
                      <Arrow active rotated={pageState.sortDirection === 'asc'} />
                    </span>
                  ) : (
                    <span class="ml-2">
                      <Arrow rotated={false} />
                    </span>
                  )}
                </div>
                <span class="tooltiptext">{INSIGHT_TOOLTIPS[insightType]}</span>
              </th>
            }
          </For>
        </tr>
      </thead>
      <tbody>
        <For each={pageState.sortedEntities}>
          {(data) =>
            <tr>
              <td>
                <a href={data.entity.html_url} target="_blank" rel="noopener noreferrer" class="inline-block w-6 h-6">
                  <img src={data.entity.avatar_url} alt="entity" class="w-6 h-6" />
                </a>
              </td>
              <td>{data.entity.login}</td>
              <For each={props.insightTypes}>
                {(insightType) => {
                  const insight = data.values[insightType];

                  if (insight.value === null) return <td>-</td>;

                  return (
                    <td>
                      <span class="whitespace-nowrap">
                        <Switch fallback={
                          <>{insight.value}</>
                        }>
                          <Match when={TIME_ATTRIBUTES.includes(insightType)}>
                            <>{toFormattedTime(insight.value)}</>
                          </Match>
                          <Match when={PERCENTILE_ATTRIBUTES.includes(insightType)}>
                            <>{`${insight.value}%`}</>
                          </Match>
                        </Switch>

                        <Show when={props.ratioType !== null && insight.ratio_value !== null}>
                          <sup class={`${ratioClass(insight.ratio_value, insightType)} ml-1 text-xs`}>
                            {valueSign(insight.ratio_value)}
                            {props.ratioType === 'change' && TIME_ATTRIBUTES.includes(insightType)
                              ? toFormattedTime(Math.abs(insight.ratio_value))
                              : Math.abs(insight.ratio_value)}
                            {props.ratioType === 'change' ? '' : '%'}
                          </sup>
                        </Show>
                      </span>
                    </td>
                  );
                }}
              </For>
            </tr>
          }
        </For>
      </tbody>
    </table>
  );
};
