import { Show, For } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Checkbox } from '../../atoms';
import { Dropdown, Select } from '../../molecules';

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
  const [pageState, setPageState] = createStore({
    // eslint-disable-next-line solid/reactivity
    insightFields: props.insightFields,
    // eslint-disable-next-line solid/reactivity
    mainAttribute: props.mainAttribute,
    // eslint-disable-next-line solid/reactivity
    averageType: props.averageType,
    // eslint-disable-next-line solid/reactivity
    insightRatio: props.insightRatio,
    // eslint-disable-next-line solid/reactivity
    insightRatioType: props.insightRatioType,
    errors: []
  });

  const toggleInsightField = async (insightName) => {
    const insightFields = pageState.insightFields.includes(insightName) ? pageState.insightFields.slice().filter((item) => item !== insightName) : [].concat(insightName, pageState.insightFields);
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { insightFields: insightFields });

    if (result.errors) setPageState('errors', result.errors);
    else {
      setPageState({
        ...pageState,
        insightFields: insightFields,
        errors: []
      });
    }
  }

  const updateMainAttribute = async (value) => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { mainAttribute: value });

    if (result.errors) setPageState('errors', result.errors);
    else {
      setPageState({
        ...pageState,
        mainAttribute: value,
        errors: []
      });
    }
  }

  const updateAverageType = async (value) => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { averageType: value });

    if (result.errors) setPageState('errors', result.errors);
    else {
      setPageState({
        ...pageState,
        averageType: value,
        errors: []
      });
    }
  }

  const toggleInsightRatio = async () => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { insightRatio: !pageState.insightRatio });

    if (result.errors) setPageState('errors', result.errors);
    else {
      setPageState({
        ...pageState,
        insightRatio: !pageState.insightRatio,
        errors: []
      });
    }
  }

  const updateInsightRatioType = async (value) => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { insightRatioType: value });

    if (result.errors) setPageState('errors', result.errors);
    else {
      setPageState({
        ...pageState,
        insightRatioType: value,
        errors: []
      });
    }
  }

  return (
    <Dropdown title="Insights">
      <div class="py-6 px-8">
        <div class="grid lg:grid-cols-2 gap-8 pb-8 mb-8 border-b border-gray-200">
          <div>
            <div class="flex flex-wrap">
              <For each={Object.entries(ATTRIBUTE_NAMES)}>
                {([insightName, label]) =>
                  <div class="w-full sm:w-1/2 mb-2">
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
          </div>
          <div>
            <p>If this configuration is enabled then you can select specific insight attributes to calculate and render such information at insight tables.</p>
          </div>
        </div>
        <div class="grid lg:grid-cols-2 gap-8 pb-8 mb-8 border-b border-gray-200">
          <div>
            <Select
              labelText="Main attribute for sorting insights"
              items={ATTRIBUTE_NAMES}
              selectedValue={pageState.mainAttribute}
              onSelect={(value) => updateMainAttribute(value)}
            />
          </div>
          <div>
            <p>By configuring main insight attribute you can set default sorting order for insights table.</p>
          </div>
        </div>
        <div class="grid lg:grid-cols-2 gap-8 pb-8 mb-8 border-b border-gray-200">
          <div>
            <Select
              labelText="Average type"
              items={AVERAGE_TYPES}
              selectedValue={pageState.averageType}
              onSelect={(value) => updateAverageType(value)}
            />
          </div>
          <div>
            <p>You can select what type of average calculation to use: arithmetic mean, geometric mean, median, etc.</p>
          </div>
        </div>
        <div class="grid lg:grid-cols-2 gap-8 mb-2">
          <div>
            <Show
              when={props.isPremium}
              fallback={<p>This configuration is available for premium accounts.</p>}
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
                    labelText="Ratio type"
                    items={RATIO_TYPES}
                    selectedValue={pageState.insightRatioType}
                    onSelect={(value) => updateInsightRatioType(value)}
                  />
                </div>
              </Show>
            </Show>
          </div>
          <div>
            <p>If this configuration enabled then each insight data will have comparison with similar data for previous period. This allows to see dynamic of changes, not only absolute values.</p>
          </div>
        </div>
      </div>
    </Dropdown>
  );
}
