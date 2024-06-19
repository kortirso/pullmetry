import React, { useState, useMemo } from 'react';

import { Dropdown } from '../../components';
import { Select } from './Select';

import { Modal, Checkbox } from '../../atoms';
import { apiRequest, csrfToken } from '../../helpers';

const NOTIFICATION_SOURCES = ['custom', 'slack', 'discord', 'telegram'];

const NOTIFICATION_TYPES = {
  insights_data: 'Insights',
  repository_insights_data: 'Repo insights',
  long_time_review_data: 'Long time review'
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

const INVITE_ACCESS_TARGETS = {
  read: 'Read',
  write: 'Write'
};

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
  invites,
  webhooks,
  companyUuid,
  notifications
}) => {
  const [pageState, setPageState] = useState({
    ingoreFormIsOpen: false,
    webhookFormIsOpen: false,
    excludeFormIsOpen: false,
    inviteFormIsOpen: false,
    ignores: ignores,
    invites: invites,
    webhooks: webhooks,
    entityValue: '',
    webhookTargetUuid: null,
    webhookSource: 'slack',
    webhookUrl: '',
    inviteEmail: '',
    inviteAccess: 'read',
    errors: [],
    notifications: notifications,
    excludeGroups: excludeGroups.data,
    excludeRules: []
  });

  const currentWebhookNotification = useMemo(() => {
    return pageState.notifications.find((element) => element.uuid === pageState.webhookTargetUuid);
  }, [pageState.notifications, pageState.webhookTargetUuid]);

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
      ignores: pageState.ignores.concat(result.result.data.attributes),
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

  const onInviteSave = async () => {
    const result = await apiRequest({
      url: '/api/frontend/invites.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({
          company_id: companyUuid,
          invite: {
            email: pageState.inviteEmail,
            access: pageState.inviteAccess
          }
        }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      inviteFormIsOpen: false,
      invites: pageState.invites.concat(result.result.data.attributes),
      inviteEmail: '',
      errors: []
    })
  };

  const onInviteRemove = async (uuid) => {
    const result = await apiRequest({
      url: `/api/frontend/invites/${uuid}.json`,
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
      invites: pageState.invites.filter((item) => item.uuid !== uuid),
      errors: []
    })
  };

  const renderInvitesList = () => {
    if (pageState.invites.length === 0) return <p>You didn't specify any invites yet.</p>;

    return (
      <div className="zebra-list">
        {pageState.invites.map((invite) => (
          <div className="zebra-list-element" key={invite.uuid}>
            <p>{invite.email}</p>
            <p>{invite.access}</p>
            <p
              className="btn-danger btn-xs"
              onClick={() => onInviteRemove(invite.uuid)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  const onWebhookSave = async () => {
    const url = pageState.webhookTargetUuid ? `/api/frontend/webhooks.json?notification_id=${pageState.webhookTargetUuid}` : `/api/frontend/webhooks.json?company_id=${companyUuid}`;
    const result = await apiRequest({
      url: url,
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ webhook: { url: pageState.webhookUrl, source: pageState.webhookTargetUuid ? null : pageState.webhookSource } }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      webhookFormIsOpen: false,
      webhooks: pageState.webhooks.concat(result.result.data.attributes),
      webhookTargetUuid: null,
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
      errors: []
    })
  };

  const renderWebhooksList = () => {
    if (pageState.webhooks.length === 0) return <p>You didn't specify any webhooks yet.</p>;

    return (
      <div className="zebra-list">
        {pageState.webhooks.map((webhook) => {
          const webhookableType = webhook.webhookable_type === 'Company' ? 'Company' : NOTIFICATION_TYPES[pageState.notifications.find((element) => element.uuid === webhook.webhookable_uuid)?.notification_type];

          return (
            <div className="zebra-list-element" key={webhook.uuid}>
              <p>{webhookableType}:{webhook.source} - {webhook.url}</p>
              <p
                className="btn-danger btn-xs"
                onClick={() => onWebhookRemove(webhook)}
              >X</p>
            </div>
          )
        })}
      </div>
    )
  };

  const onCreateNotification = async (notification_type, source) => {
    const result = await apiRequest({
      url: '/api/frontend/notifications.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ company_id: companyUuid, notification: { notification_type: notification_type, source: source } }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      notifications: pageState.notifications.concat(result.result.data.attributes),
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
      webhooks: pageState.webhooks.filter((item) => item.webhookable_uuid !== uuid),
      errors: []
    });
  };

  const renderNotificationType = (title, notification_type) => (
    <tr>
      <td>{title}</td>
      {NOTIFICATION_SOURCES.map((source) => {
        const notification = pageState.notifications.find((item) => item.source === source && item.notification_type === notification_type);
        return (
          <td key={`${notification_type}-${source}`}>
            <div className="flex">
              <Checkbox
                checked={!!notification}
                onEnable={() => onCreateNotification(notification_type, source)}
                onDisable={() => onRemoveNotification(notification.uuid)}
              />
            </div>
          </td>
        )
      })}
    </tr>
  );

  const renderNotifications = () => (
    <table className="table zebra w-full">
      <thead>
        <tr>
          <th></th>
          <th>Custom</th>
          <th>Slack</th>
          <th>Discord</th>
          <th>Telegram</th>
        </tr>
      </thead>
      <tbody>
        {renderNotificationType('Insights', 'insights_data')}
        {renderNotificationType('Repository insights', 'repository_insights_data')}
        {renderNotificationType('Long time review', 'long_time_review_data')}
      </tbody>
    </table>
  );

  const renderWebhookUrlPlaceholder = () => {
    const webhookSource = currentWebhookNotification ? currentWebhookNotification.source : pageState.webhookSource;
    if (webhookSource === 'slack') return 'https://hooks.slack.com/services/TTTTTTTTTTT/BBBBBBBBBBB/G00000000000000000000000';
    if (webhookSource === 'discord') return 'https://discord.com/api/webhooks/000111222333444555/long-key';
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
      excludeGroups: pageState.excludeGroups.concat(result.result.data),
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
              {group.attributes.excludes_rules.map((excludeRule) => (
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
      <Dropdown convertChildren={false} title="Privacy">
        <div className="py-6 px-8">
          <div
            dangerouslySetInnerHTML={{ __html: privacyHtml }}
          >
          </div>
          <div className="grid lg:grid-cols-2 gap-8 mb-8">
            <div>
              {renderInvitesList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => setPageState({ ...pageState, inviteFormIsOpen: true })}
              >Invite coworker</p>
            </div>
            <div>
              <p>In this block you can specify coworkers from company that don't have insights but it requires for them to see statistics.</p>
            </div>
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
      <Dropdown title="Insight attributes">{insightAttributesHtml}</Dropdown>
      <Dropdown title="Average type">{averageHtml}</Dropdown>
      <Dropdown title="Insights ratios">{ratiosHtml}</Dropdown>
      <Dropdown convertChildren={false} title="Notifications">
        <div className="py-6 px-8">
          <div
            dangerouslySetInnerHTML={{ __html: longTimeReviewHtml }}
          >
          </div>
          <div className="grid lg:grid-cols-2 gap-8">
            <div>
              <h5 className="mb-4">Enabled notifications</h5>
              {renderNotifications()}
              <h5 className="mt-8 mb-4">Webhooks list</h5>
              {renderWebhooksList()}
              <p
                className="btn-primary btn-small mt-8"
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
      <Dropdown title="Transfer">{transferHtml}</Dropdown>
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
              <label className="form-label">Webhookable</label>
              <sup className="leading-4">*</sup>
            </p>
            <select
              className="form-value w-full"
              value={currentWebhookNotification ? currentWebhookNotification.uuid : null}
              onChange={e => setPageState({ ...pageState, webhookTargetUuid: e.target.value })}
            >
              <option value={null}>Company</option>
              {pageState.notifications.filter((item) => item.enabled).map((notification) => (
                <option value={`${notification.uuid}`}>
                  {NOTIFICATION_TYPES[notification.notification_type]} - {notification.source}
                </option>
              ))}
            </select>
          </div>
          {currentWebhookNotification ? null : (
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
          )}
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
        show={pageState.inviteFormIsOpen}
        onClose={() => setPageState({ ...pageState, inviteFormIsOpen: false })}
      >
        <h1 className="mb-8">New invite</h1>
        <p className="mb-4">Invite will be send to email and after submitting such person will have access to company insights.</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Invite email</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              className="form-value w-full"
              value={pageState.inviteEmail}
              onChange={(e) => setPageState({ ...pageState, inviteEmail: e.target.value })}
            />
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Access level</label>
            </p>
            <Select
              items={INVITE_ACCESS_TARGETS}
              onSelect={(value) => setPageState({ ...pageState, inviteAccess: value })}
              selectedValue={pageState.inviteAccess}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onInviteSave}>Create invite</p>
        </section>
      </Modal>
    </>
  );
};
