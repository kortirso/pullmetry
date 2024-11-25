import { createEffect, createMemo, Show, Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { DeveloperInsights, RepositoryInsights, AccessTokenNewModal } from '../../../components';
import { InsightsChevron, Delete, Github, Gitlab } from '../../../assets';
import { convertDate, convertTime, csrfToken } from '../../../helpers';

import { fetchInsightsRequest } from './requests/fetchInsightsRequest';
import { fetchRepositoryInsightsRequest } from './requests/fetchRepositoryInsightsRequest';

export const Repository = (props) => {
  const [pageState, setPageState] = createStore({
    isExpanded: false,
    insightTypes: [],
    entities: undefined,
    repositoryInsights: undefined,
    ratioType: null,
  });
  let deleteForm;

  createEffect(() => {
    if (!pageState.isExpanded) return;
    if (pageState.entities !== undefined) return;

    const fetchInsights = async () => await fetchInsightsRequest(props.uuid);
    const fetchRepositoryInsights = async () => await fetchRepositoryInsightsRequest(props.uuid);

    Promise.all([fetchInsights(), fetchRepositoryInsights()]).then(
      ([insightsData, repositoryInsightsData]) => {
        setPageState({
          ...pageState,
          insightTypes: insightsData.insight_fields,
          entities: insightsData.insights,
          ratioType: insightsData.ratio_type,
          repositoryInsights: repositoryInsightsData.insight?.values,
        });
      }
    );
  });

  const developerInsights = createMemo(() => {
    if (pageState.entities === undefined) return <></>;

    return (
      <DeveloperInsights
        insightTypes={pageState.insightTypes}
        entities={pageState.entities}
        ratioType={pageState.ratioType}
        mainAttribute={props.mainAttribute}
      />
    );
  });

  const repositoryInsights = createMemo(() => {
    if (pageState.repositoryInsights === undefined) return <></>;

    return (
      <RepositoryInsights
        insights={pageState.repositoryInsights}
        ratioType={pageState.ratioType}
      />
    );
  });

  const editLinks = createMemo(() => {
    if (!props.editLinks) return <></>;

    return (
      <div class="flex items-center">
        <AccessTokenNewModal tokenable="repositories" uuid={props.uuid} required={props.accessTokenStatus === 'empty'} />
        <Show when={props.editLinks.destroy}>
          <form
            ref={deleteForm}
            method="post"
            action={props.editLinks.destroy}
            class="w-6 h-6"
            onSubmit={(event) => handleConfirm(event)}
          >
            <input type="hidden" name="_method" value="delete" autoComplete="off" />
            <input
              type="hidden"
              name="authenticity_token"
              value={csrfToken()}
              autoComplete="off"
            />
            <button type="submit" title="Delete repository" onClick={(event) => event.stopPropagation()}>
              <Delete />
            </button>
          </form>
        </Show>
      </div>
    );
  });

  const toggle = () => setPageState('isExpanded', !pageState.isExpanded);

  const handleConfirm = (event) => {
    event.preventDefault();
    event.stopPropagation();

    if (window.confirm('Are you sure you wish to delete repository?')) deleteForm.submit();
  }

  return (
    <div class="box mb-4">
      <div
        class="relative cursor-pointer p-10 flex justify-between items-center"
        onClick={toggle}
      >
        <div class="pr-4">
          <div class="flex flex-row items-center">
            <a
              href={props.repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              area-label="Visit repository page"
              onClick={(event) => event.stopPropagation()}
              class="mr-2 flex items-center"
            >
              <Show
                when={props.avatarUrl !== null}
                fallback={
                  <Switch fallback={<Github />}>
                    <Match when={props.provider === 'gitlab'}>
                      <Gitlab />
                    </Match>
                  </Switch>
                }
              >
                <img
                  src={props.avatarUrl}
                  alt="repository owner avatar"
                  class="w-8 h-8 rounded-sm"
                />
              </Show>
            </a>
            <h2>{props.title}</h2>
          </div>
          <Show
            when={props.syncedAt}
            fallback={<span>Next synchronization at {convertTime(props.nextSyncedAt)}</span>}
          >
            <span>Last synced {convertDate(props.syncedAt)} at {convertTime(props.syncedAt)}</span>
          </Show>
          <div class="sm:flex sm:flex-row sm:items-center">
            <Show when={props.accessTokenStatus === 'valid' && !props.accessable || props.accessTokenStatus === 'invalid'}>
              <span class="badge mr-2">
                Access token's update is required
              </span>
            </Show>
            <Show when={props.accessTokenStatus === 'empty'}>
              <span class="badge mr-2">
                Need to add access token
              </span>
            </Show>
          </div>
        </div>
        <InsightsChevron rotated={pageState.isExpanded} />
      </div>
      <Show when={pageState.isExpanded}>
        <div class="p-10 pt-0">
          <Switch fallback={
            <div>
              {repositoryInsights()}
              <h3>Developer insights</h3>
              {developerInsights()}
              <div class="mt-8 flex justify-between items-center">  
                <a
                  class="btn-primary btn-small"
                  href={`/api/frontend/repositories/${props.uuid}/insights.pdf`}
                  title="Click to download PDF file with insights report"
                >Download insights PDF</a>
                {editLinks()}
              </div>
            </div>
          }>
            <Match when={pageState.entities === undefined}>
              <></>
            </Match>
            <Match when={pageState.entities.length === 0}>
              <div>
                {repositoryInsights()}
                <div class="flex justify-between items-center">
                  <h3>Developer insights</h3>
                  {editLinks()}
                </div>
                <p class="light-color mt-3">There are no insights yet</p>
              </div>
            </Match>
            <Match when={pageState.insightTypes.length === 0}>
              <div>
                <div class="flex justify-between items-center">
                  <h3>Developer insights</h3>
                  {editLinks()}
                </div>
                <p class="light-color mt-3">There are no selected insight attributes yet</p>
              </div>
            </Match>
          </Switch>
        </div>
      </Show>
    </div>
  );
}
