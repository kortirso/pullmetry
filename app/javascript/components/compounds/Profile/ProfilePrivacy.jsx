import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, Dropdown, createModal, Select, createFlash } from '../../molecules';

import { createApiAccessTokenRequest } from './requests/createApiAccessTokenRequest';
import { createInviteRequest } from './requests/createInviteRequest';
import { removeApiAccessTokenRequest } from './requests/removeApiAccessTokenRequest';
import { removeInviteRequest } from './requests/removeInviteRequest';
import { removeAcceptedInviteRequest } from './requests/removeAcceptedInviteRequest';

const INVITE_ACCESS_TARGETS = {
  read: 'Read',
  write: 'Write'
};

export const ProfilePrivacy = (props) => {
  /* eslint-disable solid/reactivity */
  const [pageState, setPageState] = createStore({
    acceptedInvites: props.acceptedInvites,
    invites: props.invites,
    apiAccessTokens: props.apiAccessTokens
  });
  /* eslint-enable solid/reactivity */

  const [formStore, setFormStore] = createStore({
    email: '',
    access: 'read'
  });

  const { Modal, openModal, closeModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const onInviteCreate = async () => {
    const result = await createInviteRequest({ invite: formStore });

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        setPageState({ ...pageState, invites: pageState.invites.concat(result.result) });
        setFormStore({ email: '', access: 'read' });
        closeModal();
      });
    }
  };

  const onInviteRemove = async (uuid) => {
    const result = await removeInviteRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, invites: pageState.invites.filter((item) => item.uuid !== uuid) })
  };

  const onAcceptedInviteRemove = async (uuid) => {
    const result = await removeAcceptedInviteRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, acceptedInvites: pageState.acceptedInvites.filter((item) => item.uuid !== uuid) })
  };

  const onApiAccessTokenCreate = async () => {
    const result = await createApiAccessTokenRequest();

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, apiAccessTokens: pageState.apiAccessTokens.concat(result.result) })
  };

  const onApiAccessTokenRemove = async (id) => {
    const result = await removeApiAccessTokenRequest(id);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, apiAccessTokens: pageState.apiAccessTokens.filter((item) => item.uuid !== id) })
  };

  return (
    <>
      <Dropdown title="Privacy">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8 mb-8 pb-8 border-b border-gray-200">
            <div>
              <Show
                when={pageState.apiAccessTokens.length > 0}
                fallback={<p>You didn't specify any API access tokens yet.</p>}
              >
                <table class="table zebra w-full">
                  <tbody>
                    <For each={pageState.apiAccessTokens}>
                      {(apiAccessToken) =>
                        <tr>
                          <td>{apiAccessToken.value}</td>
                          <td class="w-12">
                            <p
                              class="btn-danger btn-xs"
                              onClick={() => onApiAccessTokenRemove(apiAccessToken.uuid)}
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
                onClick={onApiAccessTokenCreate}
              >Create API access token</p>
            </div>
            <div>
              <p class="mb-4">In this block you can create access tokens for PullKeeper's API.</p>
              <p>For getting list of available enpoints you can check <a href="https://pullkeeper.dev/api-docs/index.html" class="simple-link">API documentation</a>.</p>
            </div>
          </div>
          <div class="grid lg:grid-cols-2 gap-8 mb-2">
            <div>
              <Show when={pageState.acceptedInvites.length > 0}>
                <div class="mb-8">
                  <p class="mb-2 font-medium">Accepted invites</p>
                  <table class="table zebra w-full">
                    <tbody>
                      <For each={pageState.acceptedInvites}>
                        {(invite) =>
                          <tr>
                            <td>{invite.email}</td>
                            <td class="w-28">{INVITE_ACCESS_TARGETS[invite.access]}</td>
                            <td class="w-12">
                              <p
                                class="btn-danger btn-xs"
                                onClick={() => onAcceptedInviteRemove(invite.uuid)}
                              >X</p>
                            </td>
                          </tr>
                        }
                      </For>
                    </tbody>
                  </table>
                </div>
              </Show>
              <Show
                when={pageState.invites.length > 0}
                fallback={<p>There are no not answered invites.</p>}
              >
                <p class="mb-2 font-medium">Sent invites</p>
                <table class="table zebra w-full">
                  <tbody>
                    <For each={pageState.invites}>
                      {(invite) =>
                        <tr>
                          <td>{invite.email}</td>
                          <td class="w-28">{INVITE_ACCESS_TARGETS[invite.access]}</td>
                          <td class="w-12">
                            <p
                              class="btn-danger btn-xs"
                              onClick={() => onInviteRemove(invite.uuid)}
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
              >Invite coowner</p>
            </div>
            <div>
              <p>In this block you can specify coowners of your account.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Modal>
        <h1 class="mb-8">New invite</h1>
        <p class="mb-4">Invite will be send to email and after submitting such person will have access to your account.</p>
        <section class="inline-block w-full">
          <FormInputField
            required
            classList="w-full lg:w-3/4"
            labelText="Invite email"
            value={formStore.email}
            onChange={(value) => setFormStore('email', value)}
          />
          <Select
            required
            classList="w-full lg:w-1/2"
            labelText="Access level"
            items={INVITE_ACCESS_TARGETS}
            selectedValue={formStore.access}
            onSelect={(value) => setFormStore('access', value)}
          />
          <button class="btn-primary mt-4" onClick={onInviteCreate}>Save invite</button>
        </section>
      </Modal>
      <Flash />
    </>
  )
};

