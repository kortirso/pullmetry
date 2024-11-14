import { createEffect, createMemo, Show, Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { DeveloperInsights } from '../../../components';
import { InsightsChevron, Chevron, Delete, Edit, Key } from '../../../assets';
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
        <Show when={props.editLinks.accessToken}>
          <a
            href={props.editLinks.accessToken}
            class="mr-2"
            classList={{ ['p-0.5 bg-yellow-orange rounded-lg text-white']: props.editLinks.needAccessToken }}
            onClick={(event) => event.stopPropagation()}
          >
            <Key />
          </a>
        </Show>
        <Show when={props.editLinks.configuration}>
          <a
            href={props.editLinks.configuration}
            class="mr-2"
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
            <button type="submit" onClick={(event) => event.stopPropagation()}>
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
    <div class="company mb-4">
      <div
        class="relative cursor-pointer p-10 flex justify-between items-center"
        onClick={toggle}
      >
        <div class="pr-4">
          <h2 class="sm:flex sm:flex-row sm:items-center">
            <div>{props.title}</div>
            <Show when={props.isPrivate}>
              <span class="badge ml-4">
                Private
              </span>
            </Show>
            <Show when={props.unaccessable}>
              <span class="badge mt-4 sm:mt-0 sm:ml-4">
                Company has repositories with access error
              </span>
            </Show>
          </h2>
          <p class="flex items-center">
            {props.repositoriesCount > 0 ? (
              <>
                Repositories count -&nbsp;
                <a
                  href={props.repositoriesUrl}
                  class="underline text-orange-500"
                  onClick={(event) => event.stopPropagation()}
                >
                  {props.repositoriesCount}
                </a>
                <Show when={props.editLinks?.needAccessToken}>
                  <a
                    href={props.editLinks.accessToken}
                    class="ml-4 badge"
                    onClick={(event) => event.stopPropagation()}
                  >Need to add access token</a>
                </Show>
              </>
            ) : null}
          </p>
        </div>
        <InsightsChevron rotated={pageState.isExpanded} />
      </div>
      <Show when={pageState.isExpanded}>
        <div class="p-10 pt-0">
          <Switch fallback={
            <div class="relative">
              <h3 class="absolute top-0">Developer insights</h3>
              <div class="overflow-x-scroll pt-10">
                {developerInsights()}
                  <a
                    class="btn-primary btn-small mt-8"
                    href={`/api/frontend/companies/${props.uuid}/insights.pdf`}
                  >Download insights PDF</a>
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
                {props.repositoriesCount === 0 ? (
                  <a
                    href={props.repositoriesUrl}
                    class="badge"
                    onClick={(event) => event.stopPropagation()}
                  >
                    Need to create repository
                  </a>
                ) : null}
              </div>
            </Match>
            {/*<Match when={pageState.insightTypes.length === 0}>
              <p class="light-color">There are no selected insight attributes yet</p>
            </Match>*/}
          </Switch>
        </div>
      </Show>
    </div>
  );
}
