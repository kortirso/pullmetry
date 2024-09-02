import { Switch, Match, Show } from 'solid-js';

import { toFormattedTime } from '../../../helpers';

import { valueSign, ratioClass } from './helpers/ratio';

const TIME_ATTRIBUTES = ['average_comment_time', 'average_review_time', 'average_merge_time'];

export const RepositoryInsights = (props) => {
  const renderRepositoryInsight = (insightType) => {
    const insight = props.insights[insightType];

    if (insight.value === null) return <></>;
    return (
      <>
        <Switch fallback={
          <>{insight.value}</>
        }>
          <Match when={TIME_ATTRIBUTES.includes(insightType)}>
            <>{toFormattedTime(insight.value)}</>
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
      </>
    );
  };

  return (
    <div class="text-sm md:text-base grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
      <div class="p-4 rounded border border-stone-200">
        <h4 class="mb-4">Pull requests</h4>
        <p>Open pull requests - {renderRepositoryInsight('open_pull_requests_count')}</p>
        <p>Commented pull requests - {renderRepositoryInsight('commented_pull_requests_count')}</p>
        <p>Reviewed pull requests - {renderRepositoryInsight('reviewed_pull_requests_count')}</p>
        <p>Merged pull requests - {renderRepositoryInsight('merged_pull_requests_count')}</p>
      </div>
      <div class="p-4 rounded border border-stone-200">
        <h4 class="mb-4">Cycle time</h4>
        <p>Avg comment time - {renderRepositoryInsight('average_comment_time')}</p>
        <p>Avg review time - {renderRepositoryInsight('average_review_time')}</p>
        <p>Avg merge time - {renderRepositoryInsight('average_merge_time')}</p>
      </div>
      <div class="p-4 rounded border border-stone-200">
        <h4 class="mb-4">Additional stats</h4>
        <p>Comments - {renderRepositoryInsight('comments_count')}</p>
        <p>Good comments - {renderRepositoryInsight('conventional_comments_count')}</p>
        <p>Avg comments - {renderRepositoryInsight('average_comments_count')}</p>
        <p>Changed LOC - {renderRepositoryInsight('changed_loc')}</p>
        <p>Avg changed LOC - {renderRepositoryInsight('average_changed_loc')}</p>
      </div>
    </div>
  );
};
