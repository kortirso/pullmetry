import React, { useEffect, useState, useRef } from 'react';

import { Insights, RepositoryInsights } from '../../components';
import { convertDate, convertTime } from '../../helpers';
import { Chevron, Delete, Github, Gitlab, Key } from '../../assets';

import { insightsRequest } from './requests/insightsRequest';
import { repositoryInsightsRequest } from './requests/repositoryInsightsRequest';

export const Repository = ({
  uuid,
  avatar_url,
  title,
  synced_at,
  next_synced_at,
  provider,
  repository_url,
  access_token_status,
  accessable = true,
  main_attribute,
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
        setPageState({
          ...pageState,
          entities: insightsData.insights,
          insights: repositoryInsightsData.insight.values,
          insightTypes: insightsData.insight_fields,
          ratioType: insightsData.ratio_type,
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

  const renderSyncedAt = () => {
    if (synced_at === null) return <span>Next synchronization at {convertTime(next_synced_at)}</span>;

    return <span>Last synced {convertDate(synced_at)} at {convertTime(synced_at)}</span>;
  }

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
      <>
        <Insights
          insightTypes={pageState.insightTypes}
          entities={pageState.entities}
          ratioType={pageState.ratioType}
          mainAttribute={main_attribute}
        />
        <a
          className="btn-primary btn-small mt-4"
          href={`/api/frontend/repositories/${uuid}/insights.pdf`}
        >Download insights PDF</a>
      </>
    );
  };

  const renderRepositoryProviderLogo = () => {
    if (provider === 'gitlab') return <Gitlab />;

    return <Github />;
  };

  return (
    <div className="mb-4 bg-white rounded border border-stone-200">
      <div
        className="relative cursor-pointer p-8 flex justify-between items-center"
        onClick={() => toggle()}
      >
        <div>
          <h2 className="sm:flex sm:flex-row sm:items-center">
            <div className="flex flex-row items-center">
              {avatar_url !== null ? (
                <img
                  src={avatar_url}
                  alt="repository owner avatar"
                  className="w-8 h-8 rounded-sm mr-2"
                />
              ) : null}
              {title}
            </div>
            {access_token_status === 'valid' && !accessable ? (
              <span className="badge mt-4 sm:mt-0 sm:ml-4">
                Access token's update is required
              </span>
            ) : null}
            {access_token_status === 'invalid' ? (
              <span className="badge mt-4 sm:mt-0 sm:ml-4">
                Access token's update is required
              </span>
            ) : null}
          </h2>
          <p className="flex items center">
            <a
              href={repository_url}
              target="_blank"
              rel="noopener noreferrer"
              area-label="Visit repository page"
              onClick={(event) => event.stopPropagation()}
              className="mr-2 flex items-center"
            >
              {renderRepositoryProviderLogo()}
            </a>
            {renderSyncedAt()}
          </p>
        </div>
        <Chevron rotated={pageState.expanded} />
        {edit_links ? (
          <div className="absolute top-4 right-4 sm:top-8 sm:right-20 flex items-center">
            {access_token_status === 'empty' && edit_links ? (
              <a
                href={edit_links.access_token}
                className="badge mt-4 sm:mt-0 sm:mr-4"
                onClick={(event) => event.stopPropagation()}
              >
                Need to add access token
              </a>
            ) : null}
            {edit_links.access_token ? (
              <a
                href={edit_links.access_token}
                onClick={(event) => event.stopPropagation()}
                className={`mr-2 ${access_token_status === 'empty' && edit_links ? 'p-0.5 bg-orange-300 border border-orange-400 rounded-lg text-white' : ''}`}
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
      {pageState.expanded ? (
        <div className="pt-4 px-8 pb-8">
          {pageState.insights !== undefined ? (
            <>
              <h3 className="mb-4">Repository insights</h3>
              {renderRepositoryInsightsData()}
            </>
          ) : null}
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
