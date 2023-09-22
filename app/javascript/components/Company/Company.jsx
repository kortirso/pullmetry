import React, { useEffect, useState } from 'react';

import { Insights } from '../../components';

import { insightsRequest } from './requests/insightsRequest';

export const Company = ({ uuid, title, repositories_count, repositories_url, unaccessable }) => {
  const [pageState, setPageState] = useState({
    expanded: false,
    insightTypes: [],
    entities: undefined,
    ratioType: null,
  });

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
    <div className="mb-4">
      <div className="cursor-pointer p-8 pr-12 bg-neutral-200" onClick={() => toggle()}>
        <h2 className="flex items-center">
          {title}
          {unaccessable ? (
            <span className="text-sm px-2 py-1 bg-red-400 border border-red-600 text-white ml-4 rounded">
              Company has repositories with access error
            </span>
          ) : null}
        </h2>
        <span onClick={(event) => event.stopPropagation()}>
          Repositories count -{' '}
          <a href={repositories_url} className="underline text-blue-600">
            {repositories_count}
          </a>
        </span>
      </div>
      {pageState.expanded ? (
        <div className="p-4">
          <h2 className="mb-4">Developer insights</h2>
          {renderInsightsData()}
        </div>
      ) : null}
    </div>
  );
};
