import React, { useEffect, useState, useRef } from 'react';

import { Insights } from '../../atoms';
import { Chevron, Delete, Edit, Key } from '../../svg';

import { insightsRequest } from './requests/insightsRequest';

export const Company = ({
  uuid,
  title,
  repositories_count,
  repositories_url,
  unaccessable,
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
      const insightTypes = insightsData.length > 0 ? Object.keys(insightsData[0].values) : [];
      const ratioType = insightsData.length > 0 ? insightsData[0].ratio_type : null;
      setPageState({
        ...pageState,
        entities: insightsData,
        insightTypes: insightTypes,
        ratioType: ratioType,
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

    return (
      <Insights
        insightTypes={pageState.insightTypes}
        entities={pageState.entities}
        ratioType={pageState.ratioType}
      />
    );
  };

  return (
    <div className="mb-4 bg-white rounded shadow">
      <div
        className="cursor-pointer p-8 flex justify-between items-center"
        onClick={() => toggle()}
      >
        <div>
          <h2 className="flex items-center">
            {title}
            {unaccessable ? (
              <span className="text-sm px-2 py-1 bg-red-400 text-white ml-4 rounded shadow">
                Company has repositories with access error
              </span>
            ) : null}
          </h2>
          {repositories_count > 0 ? (
            <span onClick={(event) => event.stopPropagation()}>
              Repositories count -{' '}
              <a href={repositories_url} className="underline text-blue-600">
                {repositories_count}
              </a>
            </span>
          ) : (
            <a
              href={edit_links ? edit_links.new_repository : repositories_url}
              className="inline-block text-sm px-2 py-1 bg-green-400 text-black rounded shadow mb-1"
              onClick={(event) => event.stopPropagation()}
            >
              You need to create repository
            </a>
          )}
          {edit_links ? (
            <div className="flex items-center mt-2">
              {edit_links.access_token ? (
                <a
                  href={edit_links.access_token}
                  onClick={(event) => event.stopPropagation()}
                  className="mr-2"
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
        <Chevron rotated={pageState.expanded} />
      </div>
      {pageState.expanded ? (
        <div className="pt-4 px-8 pb-8">
          <h3 className="mb-4">Developer insights</h3>
          {renderInsightsData()}
        </div>
      ) : null}
    </div>
  );
};
