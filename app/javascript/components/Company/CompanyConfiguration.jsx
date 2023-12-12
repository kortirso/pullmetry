import React, { useState, useMemo } from 'react';

import { Dropdown, ExcludeRules } from '../../components';
import { Checkbox } from './Checkbox';

import { Modal } from '../../atoms';
import { apiRequest, csrfToken } from '../../helpers';

const NOTIFICATION_SOURCES = ['custom', 'slack', 'discord', 'telegram'];

export const CompanyConfiguration = ({
  privacyHtml,
  workTimeHtml,
  insightAttributesHtml,
  averageHtml,
  ratiosHtml,
  excludeRules,
  ignores,
  webhooks,
  companyUuid,
  notifications
}) => {
  const [pageState, setPageState] = useState({
    ingoreFormIsOpen: false,
    webhookFormIsOpen: false,
    ignores: ignores,
    webhooks: webhooks,
    entityValue: '',
    webhookSource: 'slack',
    webhookUrl: '',
    errors: [],
    notifications: notifications
  });

  const webhookSources = useMemo(() => {
    return pageState.webhooks.map((item) => item.source);
  }, [pageState.webhooks]);

  const notificationSources = useMemo(() => {
    return pageState.notifications.reduce((acc, item) => {
      if (acc[item.notification_type]) acc[item.notification_type].push(item.source);
      else acc[item.notification_type] = [item.source];

      return acc;
    }, {});
  }, [pageState.notifications]);

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

  const onWebhookRemove = async (webhook) => {
    const result = await apiRequest({
      url: `/api/frontend/webhooks/${webhook.uuid}.json`,
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
      webhooks: pageState.webhooks.filter((item) => item.uuid !== webhook.uuid),
      notifications: pageState.notifications.filter((item) => item.source !== webhook.source),
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
              onClick={() => onWebhookRemove(webhook)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  const onCreateNotification = async (notification_type, source) => {
    const result = await apiRequest({
      url: `/api/frontend/companies/${companyUuid}/notifications.json`,
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ notification: { notification_type: notification_type, source: source } }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      notifications: result.result
    });
  };

  const onRemoveNotification = async (notification_type, source) => {
    const result = await apiRequest({
      url: `/api/frontend/companies/${companyUuid}/notifications.json`,
      options: {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ notification: { notification_type: notification_type, source: source } }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      notifications: result.result
    });
  };

  const renderNotificationType = (title, notification_type) => (
    <tr>
      <td>{title}</td>
      {NOTIFICATION_SOURCES.map((source) => (
        <td key={`${notification_type}-${source}`}>
          <Checkbox
            disabled={!webhookSources.includes(source)}
            checked={notificationSources[notification_type]?.includes(source)}
            onEnable={() => onCreateNotification(notification_type, source)}
            onDisable={() => onRemoveNotification(notification_type, source)}
          />
        </td>
      ))}
    </tr>
  );

  const renderNotifications = () => (
    <table className="table zebra mt-8">
      <thead>
        <tr>
          <th></th>
          <th className={`${webhookSources.includes('custom') ? '' : 'opacity-50'}`}>Custom</th>
          <th className={`${webhookSources.includes('slack') ? '' : 'opacity-50'}`}>Slack</th>
          <th className={`${webhookSources.includes('discord') ? '' : 'opacity-50'}`}>Discord</th>
          <th className={`${webhookSources.includes('telegram') ? '' : 'opacity-50'}`}>Telegram</th>
        </tr>
      </thead>
      <tbody>
        {renderNotificationType('Insights data', 'insights_data')}
        {renderNotificationType('Repository insights data', 'repository_insights_data')}
      </tbody>
    </table>
  );

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
              {renderNotifications()}
              <p className="mt-8">For enabling notification for some channel type you need to add webhook first.</p>
            </div>
            <div>
              <p className="mb-4">For getting Slack webhook url you need to create Slack application and enabled incoming webhooks, all details you can find by url <a href="https://api.slack.com/messaging/webhooks" className="simple-link">Slack incoming webhooks</a>.</p>
              <p className="mb-4">For getting Discord webhook url you need to change settings of any channel in Discord. After selecting channel settings visit Integration / Webhooks, create webhook and copy its url.</p>
              <p>For getting Telegram chat id you need to find <span className="font-semibold">@pullkeeper_bot</span> user in Telegram, add it to your group, and by using chat command <span className="font-semibold">/get_chat_id</span> you will get chat id for using as Telegram webhook. Such id is always negative number for groups and positive for users.</p>
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
              <option value="custom">Custom</option>
              <option value="slack">Slack</option>
              <option value="discord">Discord</option>
              <option value="telegram">Telegram</option>
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
