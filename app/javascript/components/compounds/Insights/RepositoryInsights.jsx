import { Switch, Match, Show } from 'solid-js';

import { toFormattedTime } from '../../../helpers';

import { valueSign, ratioClass } from './helpers/ratio';

const TIME_ATTRIBUTES = [
  'average_comment_time',
  'average_review_time',
  'average_merge_time',
  'average_issue_comment_time',
  'average_issue_close_time'
];

export const RepositoryInsights = (props) => {
  const renderRepositoryInsight = (insightType) => {
    const insight = props.insights[insightType];
    if (insight.value === null || insight.value === undefined) return <>-</>;
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
  }

  return (
    <div class="text-sm md:text-base grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
      <div>
        <h3 class="mb-8">Repository insights</h3>
        <table class="table" cellSpacing="0">
          <thead>
            <tr>
              <th class="text-left">Metric</th>
              <th class="text-right">Value</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Pull requests amount</td>
              <td class="text-right">{renderRepositoryInsight('open_pull_requests_count')}</td>
            </tr>
            <tr>
              <td>Commented pull requests amount</td>
              <td class="text-right">{renderRepositoryInsight('commented_pull_requests_count')}</td>
            </tr>
            <tr>
              <td>Reviewed pull requests amount</td>
              <td class="text-right">{renderRepositoryInsight('reviewed_pull_requests_count')}</td>
            </tr>
            <tr>
              <td>Merged pull requests amount</td>
              <td class="text-right">{renderRepositoryInsight('merged_pull_requests_count')}</td>
            </tr>
            <tr>
              <td>Open issues amount</td>
              <td class="text-right">{renderRepositoryInsight('open_issues_count')}</td>
            </tr>
            <tr>
              <td>Closed issues amount</td>
              <td class="text-right">{renderRepositoryInsight('closed_issues_count')}</td>
            </tr>
            <tr>
              <td>Total comments amount</td>
              <td class="text-right">{renderRepositoryInsight('comments_count')}</td>
            </tr>
            <tr>
              <td>Total good comments amount</td>
              <td class="text-right">{renderRepositoryInsight('conventional_comments_count')}</td>
            </tr>
            <tr>
              <td>Average comments amount per pull request</td>
              <td class="text-right">{renderRepositoryInsight('average_comments_count')}</td>
            </tr>
            <tr>
              <td>Total changed lines of code amount</td>
              <td class="text-right">{renderRepositoryInsight('changed_loc')}</td>
            </tr>
            <tr>
              <td>Average changed lines of code per pull request</td>
              <td class="text-right">{renderRepositoryInsight('average_changed_loc')}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div>
        <h3 class="mb-8">Pull requests cycle time</h3>
        <table class="table" cellSpacing="0">
          <thead>
            <tr>
              <th class="text-left">Metric</th>
              <th class="text-right">Value</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Average time for receiving first comment</td>
              <td class="text-right">{renderRepositoryInsight('average_comment_time')}</td>
            </tr>
            <tr>
              <td>Average time for receiving first review</td>
              <td class="text-right">{renderRepositoryInsight('average_review_time')}</td>
            </tr>
            <tr>
              <td>Average time until merging pull requests</td>
              <td class="text-right">{renderRepositoryInsight('average_merge_time')}</td>
            </tr>
          </tbody>
        </table>
        <h3 class="my-8">Issues cycle time</h3>
        <table class="table" cellSpacing="0">
          <thead>
            <tr>
              <th class="text-left">Metric</th>
              <th class="text-right">Value</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Average time for receiving first comment</td>
              <td class="text-right">{renderRepositoryInsight('average_issue_comment_time')}</td>
            </tr>
            <tr>
              <td>Average time until closing</td>
              <td class="text-right">{renderRepositoryInsight('average_issue_close_time')}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}
