import React, { useEffect, useState } from 'react';

import { Chevron, Insights } from '../../atoms';

import { insightsRequest } from './requests/insightsRequest';
import { repositoryInsightsRequest } from './requests/repositoryInsightsRequest';

export const Repository = ({ uuid, title, synced_at, repository_url, unaccessable }) => {
  const [pageState, setPageState] = useState({
    expanded: false,
    insightTypes: [],
    entities: undefined,
    insights: undefined,
    ratioType: null,
  });

  useEffect(() => {
    if (!pageState.expanded) return;
    if (pageState.entities !== undefined) return;

    const fetchInsights = async () => await insightsRequest(uuid);
    const fetchRepositoryInsights = async () => await repositoryInsightsRequest(uuid);

    Promise.all([fetchInsights(), fetchRepositoryInsights()]).then(([insightsData, repositoryInsightsData]) => {
      const insightTypes = insightsData.length > 0 ? Object.keys(insightsData[0].values) : [];
      const ratioType = insightsData.length > 0 ? insightsData[0].ratio_type : null;
      setPageState({
        ...pageState,
        entities: insightsData,
        insights: Object.keys(repositoryInsightsData).length === 0 ? undefined : repositoryInsightsData,
        insightTypes: insightTypes,
        ratioType: ratioType,
      });
    });
  }, [pageState, uuid]);

  const toggle = () => setPageState({ ...pageState, expanded: !pageState.expanded });

  const renderRepositoryInsightsData = () => {
    return (
      <div className="grid grid-cols-3 gap-8 mb-8">
        <div className="p-4 border border-gray-200 rounded">
          <h4 className="mb-4">Pull requests</h4>
          <p>Open pull requests - { pageState.insights.open_pull_requests_count.value }</p>
          <p>Commented pull requests - </p>
          <p>Reviewed pull requests - </p>
          <p>Merged pull requests - </p>
        </div>
        <div className="p-4 border border-gray-200 rounded">
          <h4 className="mb-4">Cycle time</h4>
          <p>Avg comment time - </p>
          <p>Avg review time - </p>
          <p>Avg merge time - </p>
        </div>
        <div className="p-4 border border-gray-200 rounded">
          <h4 className="mb-4">Additional stats</h4>
          <p>Comments - </p>
          <p>Avg comments - </p>
          <p>Changed LOC - </p>
          <p>Avg changed LOC - </p>
        </div>
      </div>
    );
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
    <div className="mb-4 bg-white">
      <div className="cursor-pointer p-8 flex justify-between items-center" onClick={() => toggle()}>
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
        </div>
        <Chevron rotated={ pageState.expanded } />
      </div>
      {pageState.expanded ? (
        <div className="py-4 px-8">
          {pageState.insights !== undefined ? (
            <>
              <h3 className="mb-4">Repository insights</h3>
              { renderRepositoryInsightsData() }
            </>
          ) : null}
          <h3 className="mb-4">Developer insights</h3>
          { renderInsightsData() }
        </div>
      ) : null}
    </div>
  );
};
