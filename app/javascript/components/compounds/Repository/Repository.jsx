import { createEffect, createMemo, Show, Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { DeveloperInsights, RepositoryInsights } from '../../../components';
import { Chevron, Delete, Github, Gitlab, Key } from '../../../assets';
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
      },
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
    )
  });

  const repositoryInsights = createMemo(() => {
    if (pageState.repositoryInsights === undefined) return <></>;

    return (
      <RepositoryInsights
        insights={pageState.repositoryInsights}
        ratioType={pageState.ratioType}
      />
    )
  });

  const toggle = () => setPageState('isExpanded', !pageState.isExpanded);

  const handleConfirm = (event) => {
    event.preventDefault();
    event.stopPropagation();

    if (window.confirm('Are you sure you wish to delete repository?')) deleteForm.submit();
  };

  return (
    <div class="mb-4 bg-white rounded border border-stone-200">
      <div
        class="relative cursor-pointer p-8 flex justify-between items-center"
        onClick={() => toggle()}
      >
        <div>
          <h2 class="sm:flex sm:flex-row sm:items-center">
            <div class="flex flex-row items-center">
              <Show when={props.avatarUrl !== null}>
                <img
                  src={props.avatarUrl}
                  alt="repository owner avatar"
                  class="w-8 h-8 rounded-sm mr-2"
                />
              </Show>
              {props.title}
            </div>
            <Show when={props.accessTokenStatus === 'valid' && !props.accessable}>
              <span class="badge mt-4 sm:mt-0 sm:ml-4">
                Access token's update is required
              </span>
            </Show>
            <Show when={props.accessTokenStatus === 'invalid'}>
              <span class="badge mt-4 sm:mt-0 sm:ml-4">
                Access token's update is required
              </span>
            </Show>
          </h2>
          <p class="flex items center">
            <a
              href={props.repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              area-label="Visit repository page"
              onClick={(event) => event.stopPropagation()}
              class="mr-2 flex items-center"
            >
              <Switch fallback={<Github />}>
                <Match when={props.provider === 'gitlab'}>
                  <Gitlab />
                </Match>
              </Switch>
            </a>
            <Show
              when={props.syncedAt}
              fallback={<span>Next synchronization at {convertTime(props.nextSyncedAt)}</span>}
            >
              <span>Last synced {convertDate(props.syncedAt)} at {convertTime(props.syncedAt)}</span>
            </Show>
          </p>
        </div>
        <Chevron rotated={pageState.isExpanded} />
        <Show when={props.editLinks}>
          <div class="absolute top-4 right-4 sm:top-8 sm:right-20 flex items-center">
            <Show when={props.editLinks.accessToken}>
              <a
                href={props.editLinks.accessToken}
                class="mr-2"
                classList={{ ['p-0.5 bg-orange-300 border border-orange-400 rounded-lg text-white']: props.editLinks.needAccessToken }}
                onClick={(event) => event.stopPropagation()}
              >
                <Key />
              </a>
            </Show>
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
                <button type="submit" onClick={(event) => event.stopPropagation()}>
                  <Delete />
                </button>
              </form>
            </Show>
          </div>
        </Show>
      </div>
      <Show when={pageState.isExpanded}>
        <div class="pt-4 px-8 pb-8">
          <h3 class="mb-8">Repository insights</h3>
          {repositoryInsights()}
          <div class="relative">
            <h3 class="absolute top-0">Developer insights</h3>
            <div class="overflow-x-scroll pt-16">
              <Switch fallback={
                <>
                  {developerInsights()}
                  <a
                    class="btn-primary btn-small mt-8"
                    href={`/api/frontend/repositories/${props.uuid}/insights.pdf`}
                  >Download insights PDF</a>
                </>
              }>
                <Match when={pageState.entities === undefined}>
                  <></>
                </Match>
                <Match when={pageState.entities.length === 0}>
                  <p>There are no insights yet</p>
                </Match>
                <Match when={pageState.insightTypes.length === 0}>
                  <p>There are no selected insight attributes yet</p>
                </Match>
              </Switch>
            </div>
          </div>
        </div>
      </Show>
    </div>
  );
};
