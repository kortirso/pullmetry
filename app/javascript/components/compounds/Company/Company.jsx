import { createEffect, createMemo, Show, Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { DeveloperInsights } from '../../../components';
import { Chevron, Delete, Edit, Key } from '../../../assets';
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
    )
  });

  const toggle = () => setPageState('isExpanded', !pageState.isExpanded);

  const handleConfirm = (event) => {
    event.preventDefault();
    event.stopPropagation();

    if (window.confirm('Are you sure you wish to delete company?')) deleteForm.submit();
  };

  return (
    <div class="mb-4 bg-white rounded border border-stone-200">
      <div
        class="relative cursor-pointer p-8 flex justify-between items-center"
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
          <span>
            {props.repositoriesCount === 0 ? (
              <a
                href={props.repositoriesUrl}
                class="badge"
                onClick={(event) => event.stopPropagation()}
              >
                Need to create repository
              </a>
            ) : (
              <>
                Repositories count -{' '}
                <a
                  href={props.repositoriesUrl}
                  class="underline text-orange-500"
                  onClick={(event) => event.stopPropagation()}
                >
                  {props.repositoriesCount}
                </a>
              </>
            )}
          </span>
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
        </Show>
      </div>
      <Show when={pageState.isExpanded}>
        <div class="pt-4 px-8 pb-8">
          <div class="relative">
            <h3 class="absolute top-0">Developer insights</h3>
            <div class="overflow-x-scroll pt-14">
              <Switch fallback={
                <>
                  {developerInsights()}
                  <a
                    class="btn-primary btn-small mt-8"
                    href={`/api/frontend/companies/${props.uuid}/insights.pdf`}
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
