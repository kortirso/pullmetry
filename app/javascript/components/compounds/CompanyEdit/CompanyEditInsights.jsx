import { Show, For } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Checkbox } from '../../atoms';
import { Select, createFlash } from '../../molecules';

import { updateCompanyConfigurationRequest } from './requests/updateCompanyConfigurationRequest';

const ATTRIBUTE_NAMES = {
  'required_reviews_count': 'Required reviews',
  'comments_count': 'Comments',
  'conventional_comments_count': 'Good comments',
  'reviews_count': 'Reviews',
  'bad_reviews_count': 'Bad reviews',
  'review_involving': 'Review involving',
  'average_review_seconds': 'Average review time',
  'reviewed_loc': 'Reviewed LOC',
  'average_reviewed_loc': 'Average reviewed LOC',
  'open_pull_requests_count': 'Open pulls',
  'time_since_last_open_pull_seconds': 'Time since last open pull',
  'average_merge_seconds': 'Average merge time',
  'average_open_pr_comments': 'Average received comments',
  'changed_loc': 'Changed LOC',
  'average_changed_loc': 'Average changed LOC'
}

const AVERAGE_TYPES = {
  'arithmetic_mean': 'Arithmetic mean',
  'median': 'Median',
  'geometric_mean': 'Geometric mean'
}

const RATIO_TYPES = {
  'change': 'Absolute change',
  'ratio': 'Ratio'
}

export const CompanyEditInsights = (props) => {
  /* eslint-disable solid/reactivity */
  const [pageState, setPageState] = createStore({
    insightFields: props.insightFields,
    mainAttribute: props.mainAttribute,
    averageType: props.averageType,
    insightRatio: props.insightRatio,
    insightRatioType: props.insightRatioType
  });
  /* eslint-enable solid/reactivity */

  const { Flash, renderErrors } = createFlash();

  const toggleInsightField = async (insightName) => {
    const insightFields = pageState.insightFields.includes(insightName) ? pageState.insightFields.slice().filter((item) => item !== insightName) : [].concat(insightName, pageState.insightFields);
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { insight_fields: insightFields });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, insightFields: insightFields });
  }

  const updateMainAttribute = async (value) => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { main_attribute: value });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, mainAttribute: value });
  }

  const updateAverageType = async (value) => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { average_type: value });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, averageType: value });
  }

  const toggleInsightRatio = async () => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { insight_ratio: !pageState.insightRatio });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, insightRatio: !pageState.insightRatio });
  }

  const updateInsightRatioType = async (value) => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { insight_ratio_type: value });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, insightRatioType: value });
  }

  return (
    <>
      <div class="box mb-4 p-8">
        <h2 class="mb-6">Insights</h2>
        <p class="mb-6 light-color">If this configuration is enabled then you can select specific insight attributes to calculate and render such information at insight tables.</p>
        <div class="flex flex-wrap">
          <For each={Object.entries(ATTRIBUTE_NAMES)}>
            {([insightName, label]) =>
              <div class="w-full sm:w-1/2 md:w-1/3 xl:w-1/4 mb-2">
                <Checkbox
                  right
                  disabled={!props.isPremium}
                  labelText={label}
                  value={pageState.insightFields.includes(insightName)}
                  onToggle={() => toggleInsightField(insightName)}
                />
              </div>
            }
          </For>
        </div>
        <p class="mt-10 mb-6 light-color">By configuring main insight attribute you can set default sorting order for insights table.</p>
        <Select
          classList="w-full sm:w-1/2 lg:w-1/3 xl:w-1/4"
          labelText="Main attribute for sorting insights"
          items={ATTRIBUTE_NAMES}
          selectedValue={pageState.mainAttribute}
          onSelect={(value) => updateMainAttribute(value)}
        />
        <p class="mt-10 mb-6 light-color">You can select what type of average calculation to use: arithmetic mean, geometric mean, median, etc.</p>
        <Select
          classList="w-full sm:w-1/2 lg:w-1/3 xl:w-1/4"
          labelText="Average type"
          items={AVERAGE_TYPES}
          selectedValue={pageState.averageType}
          onSelect={(value) => updateAverageType(value)}
        />
        <p class="mt-10 mb-6 light-color">When insights ratio configuration is enabled then each insight data will have comparison with similar data for previous period. This allows to see dynamic of changes, not only absolute values.</p>
        <Show
          when={props.isPremium}
          fallback={<p class="light-color">This configuration is available for premium accounts.</p>}
        >
          <Checkbox
            right
            labelText="Calculate insight ratios"
            value={pageState.insightRatio}
            onToggle={() => toggleInsightRatio()}
          />
          <Show when={pageState.insightRatio}>
            <div class="mt-8">
              <Select
                classList="w-full sm:w-1/2 lg:w-1/3 xl:w-1/4"
                labelText="Ratio type"
                items={RATIO_TYPES}
                selectedValue={pageState.insightRatioType}
                onSelect={(value) => updateInsightRatioType(value)}
              />
            </div>
          </Show>
        </Show>
      </div>
      <Flash />
    </>
  );
}
