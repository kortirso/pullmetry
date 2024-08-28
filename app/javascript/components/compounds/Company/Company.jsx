import { createEffect, Show, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Chevron, Delete, Edit, Key } from '../../../assets';

import { fetchInsightsRequest } from './requests/fetchInsightsRequest';

export const Company = (props) => {
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
      batch(() => {
        setPageState('insightTypes', insightsData.insight_fields);
        setPageState('entities', insightsData.insights);
        setPageState('ratioType', insightsData.ratio_type);
      });
    });
  });

  const toggle = () => setPageState('isExpanded', !pageState.isExpanded);

  // const handleConfirm = (event) => {
  //   event.preventDefault();
  //   event.stopPropagation();

  //   if (window.confirm('Are you sure you wish to delete company?')) form.current.submit();
  // };

  // const renderInsightsData = () => {
  //   if (pageState.entities === undefined) return <></>;
  //   if (pageState.entities.length === 0) return <p>There are no insights yet</p>;
  //   if (pageState.insightTypes.length === 0) return <p>There are no selected insight attributes yet</p>;

  //   return (
  //     <>
  //       <Insights
  //         insightTypes={pageState.insightTypes}
  //         entities={pageState.entities}
  //         ratioType={pageState.ratioType}
  //         mainAttribute={main_attribute}
  //       />
  //       <a
  //         class="btn-primary btn-small mt-4"
  //         href={`/api/frontend/companies/${uuid}/insights.pdf`}
  //       >Download insights PDF</a>
  //     </>
  //   );
  // };

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
              >
                Need to create repository
              </a>
            ) : (
              <>
                Repositories count -{' '}
                <a href={props.repositoriesUrl} class="underline text-orange-500">
                  {props.repositoriesCount}
                </a>
              </>
            )}
          </span>
        </div>
        <Chevron rotated={pageState.isExpanded} />
        {props.editLinks ? (
          <div class="absolute top-4 right-4 sm:top-8 sm:right-20 flex items-center">
            <Show when={props.editLinks.accessToken}>
              <a
                href={props.editLinks.accessToken}
                class={`mr-2 ${props.editLinks.needAccessToken ? 'p-0.5 bg-orange-300 border border-orange-400 rounded-lg text-white' : ''}`}
              >
                <Key />
              </a>
            </Show>
            <Show when={props.editLinks.configuration}>
              <a
                href={props.editLinks.configuration}
                class="mr-2"
              >
                <Edit />
              </a>
            </Show>
            <Show when={props.editLinks.destroy}>
              <form
                method="post"
                action={props.editLinks.destroy}
                class="w-6 h-6"
              >
                <input type="hidden" name="_method" value="delete" autoComplete="off" />
                <input
                  type="hidden"
                  name="authenticity_token"
                  value={
                    document.querySelector("meta[name='csrf-token']")?.getAttribute('content') ||
                    ''
                  }
                  autoComplete="off"
                />
                <button type="submit">
                  <Delete />
                </button>
              </form>
            </Show>
          </div>
        ) : null}
      </div>
      <Show when={pageState.isExpanded}>
        <div class="pt-4 px-8 pb-8">
          <div class="relative">
            <h3 class="absolute top-0">Developer insights</h3>
            <div class="overflow-x-scroll pt-14" />
          </div>
        </div>
      </Show>
    </div>
  );
};
