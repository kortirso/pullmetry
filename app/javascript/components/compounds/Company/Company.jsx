import { createEffect, createMemo, Show, Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { DeveloperInsights, AccessTokenNewModal } from '../../../components';
import { InsightsChevron, Delete, Edit } from '../../../assets';
import { csrfToken } from '../../../helpers';

import { fetchInsightsRequest } from './requests/fetchInsightsRequest';

export const Company = (props) => {
  let deleteForm;

  const [pageState, setPageState] = createStore({
    isExpanded: false,
    insightTypes: [],
    entities: undefined,
    ratioType: null,
  });

  createEffect(() => {
    if (!pageState.isExpanded) return;
    if (pageState.entities !== undefined) return;

    const fetchInsights = async () => await fetchInsightsRequest(props.uuid);

    Promise.all([fetchInsights()]).then(([insightsData]) => {
      setPageState({
        ...pageState,
        insightTypes: insightsData.insight_fields,
        entities: insightsData.insights,
        ratioType: insightsData.ratio_type
      });
    });
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

  const editLinks = createMemo(() => {
    if (!props.editLinks) return <></>;

    return (
      <div class="flex items-center">
        <AccessTokenNewModal tokenable="companies" uuid={props.uuid} required={props.editLinks.needAccessToken} />
        <Show when={props.editLinks.configuration}>
          <a
            href={props.editLinks.configuration}
            class="mr-2"
            title="Edit company settings"
            onClick={(event) => event.stopPropagation()}
          >
            <Edit />
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
            <button type="submit" title="Delete company" onClick={(event) => event.stopPropagation()}>
              <Delete />
            </button>
          </form>
        </Show>
      </div>
    )
  })

  const toggle = () => setPageState('isExpanded', !pageState.isExpanded);

  const handleConfirm = (event) => {
    event.preventDefault();
    event.stopPropagation();

    if (window.confirm('Are you sure you wish to delete company?')) deleteForm.submit();
  }

  return (
    <div class="box mb-4">
      <div
        class="relative cursor-pointer p-10 flex justify-between items-center"
        onClick={toggle}
      >
        <div class="pr-4">
          <div class="flex">
            <h2>{props.title}</h2>
            <Show when={props.repositoriesCount > 0}>
              <a
                href={props.repositoriesUrl}
                class="underline text-yellow-orange font-medium ml-1"
                title="Amount of repositories in company, click to explore"
                onClick={(event) => event.stopPropagation()}
              >
                {props.repositoriesCount}
              </a>
            </Show>
          </div>
          <div class="sm:flex sm:flex-row sm:items-center">
            <Show when={props.isPrivate}>
              <span class="badge mr-2" title="Repository is private">
                Private
              </span>
            </Show>
            <Show when={props.unaccessable}>
              <span class="badge mr-2">
                Company has repositories with access error
              </span>
            </Show>
            <Show when={props.repositoriesCount === 0}>
              <a
                href={props.repositoriesUrl}
                class="badge mr-2"
                title="Click to visit page for creating repository"
                onClick={(event) => event.stopPropagation()}
              >
                Need to create repository
              </a>
            </Show>
            <Show when={props.repositoriesCount > 0 && props.editLinks?.needAccessToken}>
              <a
                href={props.editLinks.accessToken}
                class="badge mr-2"
                title="Click to visit page for adding access token"
                onClick={(event) => event.stopPropagation()}
              >Need to add access token</a>
            </Show>
          </div>
        </div>
        <InsightsChevron rotated={pageState.isExpanded} />
      </div>
      <Show when={pageState.isExpanded}>
        <div class="p-10 pt-0">
          <Switch fallback={
            <div>
              <h3>Developer insights</h3>
              {developerInsights()}
              <div class="mt-8 flex justify-between items-center">  
                <a
                  class="btn-primary btn-small"
                  href={`/api/frontend/companies/${props.uuid}/insights.pdf`}
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
