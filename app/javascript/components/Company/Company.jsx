import React, { useEffect, useState, useRef } from 'react';

import { Insights } from '../../components';
import { Chevron, Delete, Edit, Key } from '../../assets';

import { insightsRequest } from './requests/insightsRequest';

export const Company = ({
  uuid,
  title,
  repositories_count,
  repositories_url,
  unaccessable,
  is_private,
  main_attribute,
  edit_links,
}) => {
  const [pageState, setPageState] = useState({
    expanded: false,
    insightTypes: [],
    entities: undefined,
    ratioType: null,
  });
  const form = useRef();

  useEffect(() => {
    if (!pageState.expanded) return;
    if (pageState.entities !== undefined) return;

    const fetchInsights = async () => await insightsRequest(uuid);

    Promise.all([fetchInsights()]).then(([insightsData]) => {
      setPageState({
        ...pageState,
        entities: insightsData.insights,
        insightTypes: insightsData.insight_fields,
        ratioType: insightsData.ratio_type,
      });
    });
  }, [pageState, uuid]);

  const toggle = () => setPageState({ ...pageState, expanded: !pageState.expanded });

  const handleConfirm = (event) => {
    event.preventDefault();
    event.stopPropagation();

    if (window.confirm('Are you sure you wish to delete company?')) form.current.submit();
  };

  const renderInsightsData = () => {
    if (pageState.entities === undefined) return <></>;
    if (pageState.entities.length === 0) return <p>There are no insights yet</p>;
    if (pageState.insightTypes.length === 0) return <p>There are no selected insight attributes yet</p>;

    return (
      <>
        <Insights
          insightTypes={pageState.insightTypes}
          entities={pageState.entities}
          ratioType={pageState.ratioType}
          mainAttribute={main_attribute}
        />
        <a
          className="btn-primary btn-small mt-4"
          href={`/api/frontend/companies/${uuid}/insights.pdf`}
        >Download insights PDF</a>
      </>
    );
  };

  return (
    <div className="mb-4 bg-white rounded border border-stone-200">
      <div
        className="relative cursor-pointer p-8 flex justify-between items-center"
        onClick={() => toggle()}
      >
        <div className="pr-4">
          <h2 className="sm:flex sm:flex-row sm:items-center">
            <div>{title}</div>
            {is_private ? (
              <span className="badge ml-4">
                Private
              </span>
            ) : null}
            {unaccessable ? (
              <span className="badge mt-4 sm:mt-0 sm:ml-4">
                Company has repositories with access error
              </span>
            ) : null}
          </h2>
          <span onClick={(event) => event.stopPropagation()}>
            Repositories count -{' '}
            <a href={repositories_url} className="underline text-orange-500">
              {repositories_count}
            </a>
            {repositories_count === 0 ? (
              <a
                href={repositories_url}
                className="badge sm:ml-4"
                onClick={(event) => event.stopPropagation()}
              >
                Need to create repository
              </a>
            ) : null}
          </span>
        </div>
        <Chevron rotated={pageState.expanded} />
        {edit_links ? (
          <div className="absolute top-4 right-4 sm:top-8 sm:right-20 flex items-center">
            {edit_links.need_access_token ? (
              <span className="badge mr-4">
                Need to add access token
              </span>
            ) : null}
            {edit_links.access_token ? (
              <a
                href={edit_links.access_token}
                onClick={(event) => event.stopPropagation()}
                className={`mr-2 ${edit_links.need_access_token ? 'p-0.5 bg-orange-300 rounded-lg text-white' : ''}`}
              >
                <Key />
              </a>
            ) : null}
            {edit_links.configuration ? (
              <a
                href={edit_links.configuration}
                onClick={(event) => event.stopPropagation()}
                className="mr-2"
              >
                <Edit />
              </a>
            ) : null}
            {edit_links.destroy ? (
              <form
                ref={form}
                method="post"
                action={edit_links.destroy}
                className="w-6 h-6"
                onSubmit={(event) => handleConfirm(event)}
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
                <button type="submit" onClick={(event) => event.stopPropagation()}>
                  <Delete />
                </button>
              </form>
            ) : null}
          </div>
        ) : null}
      </div>
      {pageState.expanded ? (
        <div className="pt-4 px-8 pb-8">
          <div className="relative">
            <h3 className="absolute top-0">Developer insights</h3>
            <div className="overflow-x-scroll pt-14">
              {renderInsightsData()}
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
};
