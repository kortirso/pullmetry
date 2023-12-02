import React, { useState } from 'react';

import { Dropdown, ExcludeRules } from '../../components';

import { Modal } from '../../atoms';
import { apiRequest, csrfToken } from '../../helpers';

export const CompanyConfiguration = ({
  privacyHtml,
  workTimeHtml,
  insightAttributesHtml,
  averageHtml,
  ratiosHtml,
  excludeRules,
  ignores,
  webhooks,
  companyUuid
}) => {
  const [pageState, setPageState] = useState({
    ingoreFormIsOpen: false,
    webhookFormIsOpen: false,
    ignores: ignores,
    webhooks: webhooks,
    entityValue: '',
    webhookSource: 'slack',
    webhookUrl: '',
    errors: []
  });
  
  const onIgnoreSave = async () => {
    const result = await apiRequest({
      url: `/api/frontend/companies/${companyUuid}/ignores.json`,
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ ignore: { entity_value: pageState.entityValue } }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      ingoreFormIsOpen: false,
      ignores: pageState.ignores.concat(result.result),
      entityValue: '',
      errors: []
    })
  };

  const onIgnoreRemove = async (uuid) => {
    const result = await apiRequest({
      url: `/api/frontend/ignores/${uuid}.json`,
      options: {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        }
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      ignores: pageState.ignores.filter((item) => item.uuid !== uuid),
      errors: []
    })
  };

  const renderIgnoresList = () => {
    if (pageState.ignores.length === 0) return <p>You didn't specify any ignores yet.</p>;

    return (
      <div className="zebra-list">
        {pageState.ignores.map((ignore) => (
          <div className="zebra-list-element" key={ignore.uuid}>
            <p>{ignore.entity_value}</p>
            <p
              className="btn-danger btn-xs"
              onClick={() => onIgnoreRemove(ignore.uuid)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  const onWebhookSave = async () => {
    const result = await apiRequest({
      url: `/api/frontend/companies/${companyUuid}/webhooks.json`,
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ webhook: { url: pageState.webhookUrl, source: pageState.webhookSource } }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      webhookFormIsOpen: false,
      webhooks: pageState.webhooks.concat(result.result),
      webhookSource: 'slack',
      webhookUrl: '',
      errors: []
    })
  };

  const onWebhookRemove = async (uuid) => {
    const result = await apiRequest({
      url: `/api/frontend/webhooks/${uuid}.json`,
      options: {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        }
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      webhooks: pageState.webhooks.filter((item) => item.uuid !== uuid),
      errors: []
    })
  };

  const renderWebhooksList = () => {
    if (pageState.webhooks.length === 0) return <p>You didn't specify any webhooks yet.</p>;

    return (
      <div className="zebra-list">
        {pageState.webhooks.map((webhook) => (
          <div className="zebra-list-element" key={webhook.uuid}>
            <p>{webhook.source} - {webhook.url}</p>
            <p
              className="btn-danger btn-xs"
              onClick={() => onWebhookRemove(webhook.uuid)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  const renderWebhookUrlPlaceholder = () => {
    if (pageState.webhookSource === 'slack') return 'https://hooks.slack.com/services/TTTTTTTTTTT/BBBBBBBBBBB/G00000000000000000000000';
    if (pageState.webhookSource === 'discord') return 'https://discord.com/api/webhooks/000111222333444555/long-key';
    return '';
  };

  return (
    <>
      <Dropdown convertChildren={false} title="Privacy">
        <div className="py-6 px-8">
          <div
            dangerouslySetInnerHTML={{ __html: privacyHtml }}
          >
          </div>
          <div className="grid lg:grid-cols-2 gap-8">
            <div>
              {renderIgnoresList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => setPageState({ ...pageState, ingoreFormIsOpen: true })}
              >Add ignore</p>
            </div>
            <div>
              <p>In this block you can specify ignoring developers, their pull requests, comments and approves will be ignored, and because of this they will not have access to insights of this company and its repositories.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Dropdown title="Work time">{workTimeHtml}</Dropdown>
      <ExcludeRules initialRules={excludeRules} />
      <Dropdown title="Insight attributes">{insightAttributesHtml}</Dropdown>
      <Dropdown title="Average type">{averageHtml}</Dropdown>
      <Dropdown title="Insights ratios">{ratiosHtml}</Dropdown>
      <Dropdown convertChildren={false} title="Notifications">
        <div className="py-6 px-8">
          <div className="grid lg:grid-cols-2 gap-8">
            <div>
              {renderWebhooksList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => setPageState({ ...pageState, webhookFormIsOpen: true })}
              >Add webhook</p>
            </div>
            <div>
              <p className="mb-4">For getting Slack webhook url you need to create Slack application and enabled incoming webhooks, all details you can find by url <a href="https://api.slack.com/messaging/webhooks" className="simple-link">Slack incoming webhooks</a>.</p>
              <p>For getting Discord webhook url you need to change settings of any channel in Discord. After selecting channel settings visit Integration / Webhooks, create webhook and copy its url.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Modal
        show={pageState.ingoreFormIsOpen}
        onClose={() => setPageState({ ...pageState, ingoreFormIsOpen: false })}
      >
        <h1 className="mb-8">New ignore</h1>
        <p className="mb-4">You can ignore developers from company insights, it can be bots, QA or any other reason to exclude developer from access to company and repositories.</p>
        <p className="mb-4">After submitting developer's insights will be removed from statistics, future syncronizations will ignore such developer.</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Entity value</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              className="form-value w-full"
              value={pageState.entityValue}
              onChange={(e) => setPageState({ ...pageState, entityValue: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onIgnoreSave}>Save ignore</p>
        </section>
      </Modal>
      <Modal
        show={pageState.webhookFormIsOpen}
        onClose={() => setPageState({ ...pageState, webhookFormIsOpen: false })}
      >
        <h1 className="mb-8">New webhook</h1>
        <section className="inline-block w-full">
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Source</label>
              <sup className="leading-4">*</sup>
            </p>
            <select
              className="form-value w-full"
              value={pageState.webhookSource}
              onChange={e => setPageState({ ...pageState, webhookSource: e.target.value })}
            >
              <option value="slack">Slack</option>
              <option value="discord">Discord</option>
            </select>
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Url</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              className="form-value w-full"
              value={pageState.webhookUrl}
              placeholder={renderWebhookUrlPlaceholder()}
              onChange={(e) => setPageState({ ...pageState, webhookUrl: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onWebhookSave}>Save webhook</p>
        </section>
      </Modal>
    </>
  );
};
