import { Show, For, Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Arrow } from '../../../assets';
import { toFormattedTime } from '../../../helpers';

import { valueSign, ratioClass } from './helpers/ratio';

const SHORT_INSIGHT_NAMES = {
  open_pull_requests_count: 'Open pulls',
  required_reviews_count: 'Req reviews',
  comments_count: 'Comments',
  conventional_comments_count: 'Good comments',
  reviews_count: 'Reviews',
  bad_reviews_count: 'Bad reviews',
  review_involving: 'Involving',
  average_review_seconds: 'Avg RT',
  reviewed_loc: 'RLOC',
  average_reviewed_loc: 'Avg RLOC',
  average_merge_seconds: 'Avg MT',
  average_open_pr_comments: 'Avg commenting',
  changed_loc: 'CLOC',
  average_changed_loc: 'Avg CLOC',
  time_since_last_open_pull_seconds: 'TSLP',
};

const INSIGHT_TOOLTIPS = {
  open_pull_requests_count: 'Open pulls',
  required_reviews_count: 'Required reviews',
  comments_count: 'Total comments',
  conventional_comments_count: 'Good comments',
  reviews_count: 'Total reviews',
  bad_reviews_count: 'Total bad reviews',
  review_involving: 'Review involving',
  average_review_seconds: 'Avg review time',
  reviewed_loc: 'Reviewed LOC',
  average_reviewed_loc: 'Avg reviewed LOC',
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
    const isAscendantSorting = sortDirection === 'asc' && !REVERSE_ORDER_ATTRIBUTES.includes(sortBy) || sortDirection === 'desc' && REVERSE_ORDER_ATTRIBUTES.includes(sortBy);
    return entities.slice().sort((a, b) => {
      let aValueIsZero = TIME_ATTRIBUTES.includes(sortBy) && a.values[sortBy].value === 0;
      let bValueIsZero = TIME_ATTRIBUTES.includes(sortBy) && b.values[sortBy].value === 0;

      let compareResult = aValueIsZero || bValueIsZero ? (a.values[sortBy].value > b.values[sortBy].value) : (a.values[sortBy].value < b.values[sortBy].value);

      if (isAscendantSorting && compareResult || !isAscendantSorting && !compareResult) return -1;
      return 1;
    });
  }

  const [pageState, setPageState] = createStore({
    sortBy: defaultSortBy,
    sortDirection: 'desc',
    sortedEntities: sortEntities(defaultSortBy, 'desc')
  });

  const changeSorting = (insightType) => {
    if (pageState.sortBy === insightType) {
      const sortDirection = pageState.sortDirection === 'asc' ? 'desc' : 'asc';
      setPageState({
        ...pageState,
        sortDirection: sortDirection,
        sortedEntities: sortEntities(pageState.sortBy, sortDirection)
      });
    } else {
      setPageState({
        sortBy: insightType,
        sortDirection: 'desc',
        sortedEntities: sortEntities(insightType, 'desc')
      });
    }
  }

  return (
    <div class="table-wrapper mt-4">
      <table class="table w-full first-column-small" cellSpacing="0">
        <thead>
          <tr>
            <th />
            <th class="text-left">Developer</th>
            <For each={props.insightTypes}>
              {(insightType) =>
                <th
                  class="cursor-pointer"
                  title={INSIGHT_TOOLTIPS[insightType]}
                  onClick={() => changeSorting(insightType)}
                >
                  <div class="flex flex-row items-center">
                    <span class="whitespace-nowrap mr-2">{SHORT_INSIGHT_NAMES[insightType]}</span>
                    <Show when={pageState.sortBy === insightType} fallback={<Arrow rotated={false} />}>
                      <Arrow active rotated={pageState.sortDirection === 'asc'} />
                    </Show>
                  </div>
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
    </div>
  );
}
