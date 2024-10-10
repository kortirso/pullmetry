import { Show, For, batch, createMemo } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, Dropdown, Select, createModal, createFlash } from '../../molecules';

import { createWebhookRequest } from './requests/createWebhookRequest';
import { removeWebhookRequest } from './requests/removeWebhookRequest';

const WEBHOOK_SOURCES = {
  'custom': 'Custom',
  'slack': 'Slack',
  'discord': 'Discord',
  'telegram': 'Telegram',
}

export const CompanyEditNotifications = (props) => {
  /* eslint-disable solid/reactivity */
  const [pageState, setPageState] = createStore({
    webhooks: props.webhooks,
    notifications: props.notifications
  });
  /* eslint-enable solid/reactivity */

  const [webhookFormStore, setWebhookFormStore] = createStore({
    source: 'slack',
    url: ''
  });

  const { Modal, openModal, closeModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const webhookUrlPlaceholder = createMemo(() => {
    if (webhookFormStore.source === 'slack') return 'https://hooks.slack.com/services/TTTTTTTTTTT/BBBBBBBBBBB/G00000000000000000000000';
    if (webhookFormStore.source === 'discord') return 'https://discord.com/api/webhooks/000111222333444555/long-key';
    return '';
  });

  const saveWebhook = async () => {
    const result = await createWebhookRequest({ webhook: webhookFormStore, companyId: props.companyUuid });

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        setPageState({ ...pageState, webhooks: pageState.webhooks.concat(result.result) });
        setWebhookFormStore({ source: 'slack', url: '' });
        closeModal();
      });
    }
  }

  const removeWebhook = async (uuid) => {
    const result = await removeWebhookRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, webhooks: pageState.webhooks.filter((item) => item.uuid !== uuid) });
  }

  return (
    <>
      <Dropdown title="Notifications">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8 mb-2">
            <div>
              <Show
                when={pageState.webhooks.length > 0}
                fallback={<p>There are no webhooks yet.</p>}
              >
                <p class="mb-2 font-medium">Webhooks list</p>
                <table class="table zebra w-full">
                  <tbody>
                    <For each={pageState.webhooks}>
                      {(webhook) =>
                        <tr>
                          <td>{webhook.source}</td>
                          <td>{webhook.url}</td>
                          <td class="w-12">
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
              </Show>
              <p
                class="btn-primary btn-small mt-8"
                onClick={openModal}
              >Add webhook</p>

              
            </div>
            <div>
              <p class="mb-4">For getting Slack webhook url you need to create Slack application and enabled incoming webhooks, all details you can find by url <a href="https://api.slack.com/messaging/webhooks" class="simple-link">Slack incoming webhooks</a>.</p>
              <p class="mb-4">For getting Discord webhook url you need to change settings of any channel in Discord. After selecting channel settings visit Integration / Webhooks, create webhook and copy its url.</p>
              <p class="mb-4">For getting Telegram chat id you need to find <span class="font-semibold">@pullkeeper_bot</span> user in Telegram, add it to your group, and by using chat command <span class="font-semibold">/get_chat_id</span> you will get chat id for using as Telegram webhook. Such id is always negative number for groups and positive for users.</p>
              <p>If notification is enabled for at least one source then it will be send to url of notification's webhook or if not present to company's webhook. So you can send different notifications to one channel or to different channels.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Modal>
        <h1 class="mb-8">New webhook</h1>
        <section class="inline-block w-full">
          <Select
            classList="w-full"
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
          <button class="btn-primary mt-4" onClick={saveWebhook}>Save webhook</button>
        </section>
      </Modal>
      <Flash />
    </>
  );
}
