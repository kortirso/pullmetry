import React, { useState, useMemo } from 'react';

import { Dropdown, Modal, Select } from '../../atoms';
import { apiRequest, csrfToken } from '../../helpers';

const NOTIFICATION_TYPES = {
  insights_data: 'Insights',
  repository_insights_data: 'Repo insights',
  long_time_review_data: 'Long time review',
  no_new_pulls_data: 'No new pull requests'
};

const EXCLUDE_RULES_TARGETS = {
  title: 'Title',
  description: 'Description',
  branch_name: 'Branch name',
  destination_branch_name: 'Target branch name'
};

const EXCLUDE_RULES_CONDITIONS = {
  equal: 'Equal',
  not_equal: 'Not equal',
  contain: 'Contain',
  not_contain: 'Not contain'
}

export const CompanyConfiguration = ({
  privacyHtml,
  fetchPeriodHtml,
  longTimeReviewHtml,
  workTimeHtml,
  insightAttributesHtml,
  averageHtml,
  ratiosHtml,
  transferHtml,
  excludeGroups,
  ignores,
  webhooks,
  companyUuid,
  notifications
}) => {
  const [pageState, setPageState] = useState({
    ingoreFormIsOpen: false,
    webhookFormIsOpen: false,
    notificationFormIsOpen: false,
    excludeFormIsOpen: false,
    inviteFormIsOpen: false,
    ignores: ignores,
    webhooks: webhooks,
    entityValue: '',
    webhookSource: 'slack',
    webhookUrl: '',
    notificationType: 'insights_data',
    notificationWebhookUuid: webhooks.length > 0 ? webhooks[0].uuid : null,
    inviteEmail: '',
    inviteAccess: 'read',
    errors: [],
    notifications: notifications,
    excludeGroups: excludeGroups,
    excludeRules: []
  });

  const webhooksForSelect = useMemo(() => {
    return pageState.webhooks.reduce((result, webhook) => {
      result[webhook.uuid] = `${webhook.source}: ${webhook.url}`
      return result;
    }, {});
  }, [pageState.webhooks]);

  const onIgnoreSave = async () => {
    const result = await apiRequest({
      url: '/api/frontend/ignores.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ company_id: companyUuid, ignore: { entity_value: pageState.entityValue } }),
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
    const url = '/api/frontend/webhooks.json';
    const result = await apiRequest({
      url: url,
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({
          company_id: companyUuid,
          webhook: {
            url: pageState.webhookUrl,
            source: pageState.webhookSource
          }
        }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else {
      const webhooks = pageState.webhooks.concat(result.result);
      const notificationWebhookUuid = webhooks.length === 1 ? webhooks[0].uuid : pageState.notificationWebhookUuid;
      setPageState({
        ...pageState,
        webhookFormIsOpen: false,
        webhooks: webhooks,
        webhookSource: 'slack',
        webhookUrl: '',
        notificationWebhookUuid: notificationWebhookUuid,
        errors: []
      })
    }
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
      notifications: pageState.notifications.filter((item) => item.webhooks_uuid !== uuid),
      errors: []
    })
  };

  const renderWebhooksList = () => {
    if (pageState.webhooks.length === 0) return <p>You didn't specify any webhooks yet.</p>;

    return (
      <table className="table zebra w-full">
        <thead>
          <tr>
            <th>UUID</th>
            <th>Source</th>
            <th>Url</th>
            <th className="w-12"></th>
          </tr>
        </thead>
        <tbody>
          {pageState.webhooks.map((webhook) => (
            <tr key={webhook.uuid}>
              <td>{webhook.uuid}</td>
              <td>{webhook.source}</td>
              <td>{webhook.url}</td>
              <td>
                <p
                  className="btn-danger btn-xs"
                  onClick={() => onWebhookRemove(webhook.uuid)}
                >X</p>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    )
  };

  const onNotificationSave = async () => {
    const result = await apiRequest({
      url: '/api/frontend/notifications.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({
          company_id: companyUuid,
          webhook_id: pageState.notificationWebhookUuid,
          notification: {
            notification_type: pageState.notificationType
          }
        }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      notificationFormIsOpen: false,
      notifications: pageState.notifications.concat(result.result),
      errors: []
    });
  };

  const onRemoveNotification = async (uuid) => {
    const result = await apiRequest({
      url: `/api/frontend/notifications/${uuid}.json`,
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
      notifications: pageState.notifications.filter((item) => item.uuid !== uuid),
      errors: []
    });
  };

  const renderNotificationsList = () => {
    if (pageState.notifications.length === 0) return <p>You didn't specify any notifications yet.</p>;

    return (
      <table className="table zebra w-full">
        <thead>
          <tr>
            <th>Source</th>
            <th>Url</th>
            <th>Type</th>
            <th className="w-12"></th>
          </tr>
        </thead>
        <tbody>
          {pageState.notifications.map((notification) => {
            const webhook = pageState.webhooks.find((item) => item.uuid === notification.webhooks_uuid);
            return (
              <tr key={notification.uuid}>
                <td>{webhook.source}</td>
                <td>{webhook.url}</td>
                <td>{NOTIFICATION_TYPES[notification.notification_type]}</td>
                <td>
                  <p
                    className="btn-danger btn-xs"
                    onClick={() => onRemoveNotification(notification.uuid)}
                  >X</p>
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    )
  };

  const renderWebhookUrlPlaceholder = () => {
    if (pageState.webhookSource === 'slack') return 'https://hooks.slack.com/services/TTTTTTTTTTT/BBBBBBBBBBB/G00000000000000000000000';
    if (pageState.webhookSource === 'discord') return 'https://discord.com/api/webhooks/000111222333444555/long-key';
    return '';
  };

  const onExcludeSave = async () => {
    const result = await apiRequest({
      url: '/api/frontend/excludes/groups.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ company_id: companyUuid, excludes_rules: pageState.excludeRules })
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      excludeFormIsOpen: false,
      excludeGroups: pageState.excludeGroups.concat(result.result),
      excludeRules: [],
      errors: []
    })
  };

  const onExcludeGroupRemove = async (group) => {
    const result = await apiRequest({
      url: `/api/frontend/excludes/groups/${group.id}.json`,
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
      excludeGroups: pageState.excludeGroups.filter((item) => item.id !== group.id),
      errors: []
    })
  };

  const addExcludeRule = () => {
    setPageState({
      ...pageState,
      excludeRules: pageState.excludeRules.concat({
        uuid: Math.floor(Math.random() * 1000).toString(),
        target: 'title',
        condition: 'equal',
        value: ''
      })
    })
  };

  const onExcludeRuleRemove = (rule) => {
    setPageState({
      ...pageState,
      excludeRules: pageState.excludeRules.filter((item) => item.uuid !== rule.uuid)
    })
  };

  const updateExcludeRule = (rule, field, value) => {
    const excludeRules = pageState.excludeRules.map((element) => {
      if (element.uuid !== rule.uuid) return element;

      element[field] = value;
      return element;
    });
    setPageState({ ...pageState, excludeRules: excludeRules });
  };

  const renderExcludesList = () => {
    if (pageState.excludeGroups.length === 0) return <p>You didn't specify any exclude rules yet.</p>;

    return (
      <div className="zebra-list">
        {pageState.excludeGroups.map((group) => (
          <div className="zebra-list-element" key={group.id}>
            <div className="flex flex-col">
              {group.excludes_rules.map((excludeRule) => (
                <p key={excludeRule.uuid}>
                  {EXCLUDE_RULES_TARGETS[excludeRule.target]} {excludeRule.condition.split('_').join(' ')} {excludeRule.value}
                </p>
              ))}
            </div>
            <p
              className="btn-danger btn-xs"
              onClick={() => onExcludeGroupRemove(group)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  const renderExcludeRulesList = () => {
    return pageState.excludeRules.map((rule) => (
      <div className="grid grid-cols-11 gap-2 items-center mb-4" key={rule.uuid}>
        <div className="form-field mb-0 col-span-4">
          <Select
            items={EXCLUDE_RULES_TARGETS}
            onSelect={(value) => updateExcludeRule(rule, 'target', value)}
            selectedValue={rule.target}
          />
        </div>
        <div className="form-field mb-0 col-span-3">
          <Select
            items={EXCLUDE_RULES_CONDITIONS}
            onSelect={(value) => updateExcludeRule(rule, 'condition', value)}
            selectedValue={rule.condition}
          />
        </div>
        <div className="form-field mb-0 col-span-3">
          <input
            className="form-value w-full text-sm"
            defaultValue={rule.value}
            onChange={(event) => updateExcludeRule(rule, 'value', event.target.value)}
          />
        </div>
        <div className="col-span-1">
          <p
            className="btn-danger btn-xs"
            onClick={() => onExcludeRuleRemove(rule)}
          >X</p>
        </div>
      </div>
    ))
  };

  return (
    <>
      <Dropdown title="Work time">{workTimeHtml}</Dropdown>
      <Dropdown convertChildren={false} title="Pull requests">
        <div className="py-6 px-8">
          <div
            dangerouslySetInnerHTML={{ __html: fetchPeriodHtml }}
          >
          </div>
          <div className="grid lg:grid-cols-2 gap-8">
            <div>
              {renderExcludesList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => setPageState({ ...pageState, excludeFormIsOpen: true })}
              >Add exclude group</p>
            </div>
            <div>
              <p>You can select rules for excluding pull requests from statistics calculations, usually it can be releases, hotfixes to master branch or synchronize pull requests from master branch.</p>
              <p className="mt-2">Pull request will be excluded if at least 1 group of rules is match.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Dropdown convertChildren={false} title="Notifications">
        <div className="py-6 px-8">
          <div
            dangerouslySetInnerHTML={{ __html: longTimeReviewHtml }}
          >
          </div>
          <div className="grid lg:grid-cols-2 gap-8">
            <div>
              <h5 className="mb-4">Enabled notifications list</h5>
              {renderNotificationsList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => setPageState({ ...pageState, notificationFormIsOpen: true })}
              >Add notification</p>
              <h5 className="mt-12 mb-4">Webhooks list</h5>
              {renderWebhooksList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => setPageState({ ...pageState, webhookFormIsOpen: true })}
              >Add webhook</p>
            </div>
            <div>
              <p className="mb-4">For getting Slack webhook url you need to create Slack application and enabled incoming webhooks, all details you can find by url <a href="https://api.slack.com/messaging/webhooks" className="simple-link">Slack incoming webhooks</a>.</p>
              <p className="mb-4">For getting Discord webhook url you need to change settings of any channel in Discord. After selecting channel settings visit Integration / Webhooks, create webhook and copy its url.</p>
              <p className="mb-4">For getting Telegram chat id you need to find <span className="font-semibold">@pullkeeper_bot</span> user in Telegram, add it to your group, and by using chat command <span className="font-semibold">/get_chat_id</span> you will get chat id for using as Telegram webhook. Such id is always negative number for groups and positive for users.</p>
              <p>If notification is enabled for at least one source then it will be send to url of notification's webhook or if not present to company's webhook. So you can send different notifications to one channel or to different channels.</p>
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
      <Modal
        show={pageState.excludeFormIsOpen}
        onClose={() => setPageState({ ...pageState, excludeFormIsOpen: false })}
      >
        <h1 className="mb-8">New exclude rules group</h1>
        <p className="mb-4">Pull request will be excluded if all rules of group match.</p>
        <section className="inline-block w-full">
          {renderExcludeRulesList()}
          <div>
            <p
              className="btn-primary btn-small mt-4"
              onClick={addExcludeRule}
            >Add exclude rule</p>
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600 mt-4">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary btn-small mt-4" onClick={onExcludeSave}>Save exclude rules</p>
        </section>
      </Modal>
      <Modal
        show={pageState.notificationFormIsOpen}
        onClose={() => setPageState({ ...pageState, notificationFormIsOpen: false })}
      >
        <h1 className="mb-8">New notification</h1>
        {pageState.webhooks.length > 0 ? (
          <section className="inline-block w-full">
            
            <div className="form-field">
              <p className="flex flex-row">
                <label className="form-label">Type</label>
              </p>
              <Select
                items={NOTIFICATION_TYPES}
                onSelect={(value) => setPageState({ ...pageState, notificationType: value })}
                selectedValue={pageState.notificationType}
              />
            </div>

            <div className="form-field">
              <p className="flex flex-row">
                <label className="form-label">Webhook</label>
              </p>
              <Select
                items={webhooksForSelect}
                onSelect={(value) => setPageState({ ...pageState, notificationWebhookUuid: value })}
                selectedValue={pageState.notificationWebhookUuid}
              />
            </div>

            {pageState.errors.length > 0 ? (
              <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
            ) : null}
            <p className="btn-primary mt-4" onClick={onNotificationSave}>Save notification</p>
          </section>
        ) : (
          <section className="inline-block w-full">
            <p>You need to create at least 1 webhook first.</p>
          </section>
        )}
      </Modal>
    </>
  );
};
