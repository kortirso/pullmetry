import React, { useEffect, useState, useRef } from 'react';

import { Insights, RepositoryInsights } from '../../atoms';
import { Chevron, Delete, Key } from '../../icons';

import { insightsRequest } from './requests/insightsRequest';
import { repositoryInsightsRequest } from './requests/repositoryInsightsRequest';

export const Repository = ({
  uuid,
  title,
  synced_at,
  repository_url,
  unaccessable,
  edit_links,
}) => {
  const [pageState, setPageState] = useState({
    expanded: false,
    insightTypes: [],
    entities: undefined,
    insights: undefined,
    ratioType: null,
  });
  const form = useRef();

  useEffect(() => {
    if (!pageState.expanded) return;
    if (pageState.entities !== undefined) return;

    const fetchInsights = async () => await insightsRequest(uuid);
    const fetchRepositoryInsights = async () => await repositoryInsightsRequest(uuid);

    Promise.all([fetchInsights(), fetchRepositoryInsights()]).then(
      ([insightsData, repositoryInsightsData]) => {
        const insightTypes = insightsData.length > 0 ? Object.keys(insightsData[0].values) : [];
        const ratioType = insightsData.length > 0 ? insightsData[0].ratio_type : null;
        setPageState({
          ...pageState,
          entities: insightsData,
          insights:
            Object.keys(repositoryInsightsData).length === 0 ? undefined : repositoryInsightsData,
          insightTypes: insightTypes,
          ratioType: ratioType,
        });
      },
    );
  }, [pageState, uuid]);

  const toggle = () => setPageState({ ...pageState, expanded: !pageState.expanded });

  const handleConfirm = (event) => {
    event.preventDefault();
    event.stopPropagation();

    if (window.confirm('Are you sure you wish to delete repository?')) form.current.submit();
  };

  const renderRepositoryInsightsData = () => (
    <RepositoryInsights
      insightTypes={pageState.insightTypes}
      insights={pageState.insights}
      ratioType={pageState.ratioType}
    />
  );

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
              <span className="text-sm px-2 py-1 bg-red-400 border border-red-600 text-white ml-4 rounded">
                Repository access error
              </span>
            ) : null}
          </h2>
          <p>Last synced at: {synced_at}</p>
          <a
            href={repository_url}
            target="_blank"
            rel="noopener noreferrer"
            className="underline text-blue-600"
            onClick={(event) => event.stopPropagation()}
          >
            Repository's external link
          </a>
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
          {pageState.insights !== undefined ? (
            <>
              <h3 className="mb-4">Repository insights</h3>
              {renderRepositoryInsightsData()}
            </>
          ) : null}
          <h3 className="mb-4">Developer insights</h3>
          {renderInsightsData()}
        </div>
      ) : null}
    </div>
  );
};
