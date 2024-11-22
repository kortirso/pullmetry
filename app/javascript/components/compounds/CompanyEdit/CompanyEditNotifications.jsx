import { Show, For, batch, createMemo, Switch, Match } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, Select, createModal, createFlash } from '../../molecules';
import { objectKeysToCamelCase } from '../../../helpers';

import { createWebhookRequest } from './requests/createWebhookRequest';
import { removeWebhookRequest } from './requests/removeWebhookRequest';
import { createNotificationRequest } from './requests/createNotificationRequest';
import { removeNotificationRequest } from './requests/removeNotificationRequest';

const WEBHOOK_SOURCES = {
  'custom': 'Custom',
  'slack': 'Slack',
  'discord': 'Discord',
  'telegram': 'Telegram',
}

const NOTIFICATION_TYPES = {
  insights_data: 'Insights',
  repository_insights_data: 'Repository insights',
  long_time_review_data: 'Long time review',
  no_new_pulls_data: 'No new pull requests'
}

export const CompanyEditNotifications = (props) => {
  /* eslint-disable solid/reactivity */
  const [pageState, setPageState] = createStore({
    webhooks: props.webhooks,
    notifications: props.notifications,
    webhookModalIsOpen: false,
    notificationModalIsOpen: false
  });

  const [webhookFormStore, setWebhookFormStore] = createStore({
    source: 'slack',
    url: ''
  });

  const [notificationFormStore, setNotificationFormStore] = createStore({
    notificationType: 'insights_data',
    notificationWebhookUuid: props.webhooks.length > 0 ? props.webhooks[0].uuid : null,
  });
  /* eslint-enable solid/reactivity */

  const { Modal, openModal, closeModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const webhookUrlPlaceholder = createMemo(() => {
    if (webhookFormStore.source === 'slack') return 'https://hooks.slack.com/services/TTTTTTTTTTT/BBBBBBBBBBB/G00000000000000000000000';
    if (webhookFormStore.source === 'discord') return 'https://discord.com/api/webhooks/000111222333444555/long-key';
    return '';
  });

  const webhooksForSelect = createMemo(() => {
    return pageState.webhooks.reduce((result, webhook) => {
      result[webhook.uuid] = `${webhook.source}: ${webhook.url}`
      return result;
    }, {});
  });

  const openWebhookModal = () => {
    batch(() => {
      setPageState({ ...pageState, webhookModalIsOpen: true, notificationModalIsOpen: false });
      openModal();
    });
  }

  const saveWebhook = async () => {
    const result = await createWebhookRequest({ webhook: webhookFormStore, companyId: props.companyUuid });

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        const webhooks = pageState.webhooks.concat(result.result);
        const notificationWebhookUuid = webhooks.length === 1 ? webhooks[0].uuid : notificationFormStore.notificationWebhookUuid;

        setPageState({ ...pageState, webhooks: webhooks, webhookModalIsOpen: false });
        setWebhookFormStore({ source: 'slack', url: '' });
        setNotificationFormStore({ ...notificationFormStore, notificationWebhookUuid: notificationWebhookUuid });
        closeModal();
      });
    }
  }

  const removeWebhook = async (uuid) => {
    const result = await removeWebhookRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({
      ...pageState,
      webhooks: pageState.webhooks.filter((item) => item.uuid !== uuid),
      notifications: pageState.notifications.filter((item) => item.webhooksUuid !== uuid)
    });
  }

  const openNotificationModal = () => {
    batch(() => {
      setPageState({ ...pageState, notificationModalIsOpen: true, webhookModalIsOpen: false });
      openModal();
    });
  }

  const saveNotification = async () => {
    const result = await createNotificationRequest({
      notification: { notificationType: notificationFormStore.notificationType },
      webhookId: notificationFormStore.notificationWebhookUuid,
      companyId: props.companyUuid
    });

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        setPageState({ ...pageState, notifications: pageState.notifications.concat(objectKeysToCamelCase(result.result)), notificationModalIsOpen: false });
        setNotificationFormStore({ ...notificationFormStore, notificationType: 'insights_data' });
        closeModal();
      });
    }
  }

  const removeNotification = async (uuid) => {
    const result = await removeNotificationRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, notifications: pageState.notifications.filter((item) => item.uuid !== uuid) });
  }

  return (
    <>
      <div class="box mb-4 p-8">
        <h2 class="mb-2">Notifications</h2>
        <p class="mb-4 light-color">For getting Slack webhook url you need to create Slack application and enabled incoming webhooks, all details you can find by url <a href="https://api.slack.com/messaging/webhooks" class="simple-link">Slack incoming webhooks</a>.</p>
        <p class="mb-4 light-color">For getting Discord webhook url you need to change settings of any channel in Discord. After selecting channel settings visit Integration / Webhooks, create webhook and copy its url.</p>
        <p class="mb-4 light-color">For getting Telegram chat id you need to find <span class="font-medium">@pullkeeper_bot</span> user in Telegram, add it to your group, and by using chat command <span class="font-medium">/get_chat_id</span> you will get chat id for using as Telegram webhook. Such id is always negative number for groups and positive for users.</p>
        <p class="mb-6 light-color">If notification is enabled for at least one source then it will be send to url of notification's webhook or if not present to company's webhook. So you can send different notifications to one channel or to different channels.</p>
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-end">
          <Show
            when={pageState.webhooks.length > 0}
            fallback={<p>There are no webhooks yet.</p>}
          >
            <div class="table-wrapper w-fit">
              <table class="table">
                <tbody>
                  <For each={pageState.webhooks}>
                    {(webhook) =>
                      <tr>
                        <td>{webhook.source}</td>
                        <td>{webhook.url}</td>
                        <td class="!min-w-0">
                          <p
                            class="btn-danger btn-xs"
                            onClick={() => removeWebhook(webhook.uuid)}
                          >X</p>
                        </td>
                      </tr>
                    }
                  </For>
                </tbody>
              </table>
            </div>
          </Show>
          <p class="flex lg:justify-center mt-6 lg:mt-0">
            <button
              class="btn-primary btn-small"
              onClick={openWebhookModal}
            >Add webhook</button>
          </p>
        </div>
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-end mt-6">
          <Show
            when={pageState.notifications.length > 0}
            fallback={<p>There are no notifications yet.</p>}
          >
            <div class="table-wrapper w-fit">
              <table class="table">
                <thead>
                  <tr>
                    <th class="text-left">Type</th>
                    <th class="text-left">Source</th>
                    <th class="text-left">Url</th>
                    <th class="!min-w-0" />
                  </tr>
                </thead>
                <tbody>
                  <For each={pageState.notifications}>
                    {(notification) => {
                      const webhook = pageState.webhooks.find((item) => item.uuid === notification.webhooksUuid);

                      return (
                        <tr>
                          <td>{NOTIFICATION_TYPES[notification.notificationType]}</td>
                          <td>{webhook.source}</td>
                          <td>{webhook.url}</td>
                          <td class="!min-w-0">
                            <p
                              class="btn-danger btn-xs"
                              onClick={() => removeNotification(notification.uuid)}
                            >X</p>
                          </td>
                        </tr>
                      )
                    }}
                  </For>
                </tbody>
              </table>
            </div>
          </Show>
          <p class="flex lg:justify-center mt-6 lg:mt-0">
            <button
              class="btn-primary btn-small"
              onClick={openNotificationModal}
            >Add notification</button>
          </p>
        </div>
      </div>
      <Modal>
        <Switch>
          <Match when={pageState.webhookModalIsOpen}>
            <div class="flex flex-col items-center">
              <h1 class="mb-2">New webhook</h1>
              <p class="mb-8 text-center">You can specity url and type of webhooks where messages with insights will be send.</p>
              <section class="inline-block w-4/5">
                <Select
                  classList="w-full mb-8"
                  labelText="Source"
                  items={WEBHOOK_SOURCES}
                  selectedValue={webhookFormStore.source}
                  onSelect={(value) => setWebhookFormStore('source', value)}
                />
                <FormInputField
                  required
                  classList="w-full"
                  labelText="Url"
                  placeholder={webhookUrlPlaceholder()}
                  value={webhookFormStore.url}
                  onChange={(value) => setWebhookFormStore('url', value)}
                />
                <div class="flex">
                  <button class="btn-primary mt-8 mx-auto" onClick={saveWebhook}>Save</button>
                </div>
              </section>
            </div>
          </Match>
          <Match when={pageState.notificationModalIsOpen}>
            <div class="flex flex-col items-center">
              <h1 class="mb-8">New notification</h1>
              <section class="inline-block w-4/5">
                <Show
                  when={pageState.webhooks.length > 0}
                  fallback={<p class="text-center">First you need to create at least 1 webhook.</p>}
                >
                  <Select
                    classList="w-full mb-8"
                    labelText="Type"
                    items={NOTIFICATION_TYPES}
                    selectedValue={notificationFormStore.notificationType}
                    onSelect={(value) => setNotificationFormStore('notificationType', value)}
                  />
                  <Select
                    classList="w-full"
                    labelText="Webhook"
                    items={webhooksForSelect()}
                    selectedValue={notificationFormStore.notificationWebhookUuid}
                    onSelect={(value) => setNotificationFormStore('notificationWebhookUuid', value)}
                  />
                  <div class="flex">
                    <button class="btn-primary mt-8 mx-auto" onClick={saveNotification}>Save</button>
                  </div>
                </Show>
              </section>
            </div>
          </Match>
        </Switch>
      </Modal>
      <Flash />
    </>
  );
}
