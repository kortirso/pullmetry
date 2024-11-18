import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, createModal, Select, createFlash } from '../../molecules';

import { createApiAccessTokenRequest } from './requests/createApiAccessTokenRequest';
import { createInviteRequest } from './requests/createInviteRequest';
import { removeApiAccessTokenRequest } from './requests/removeApiAccessTokenRequest';
import { removeInviteRequest } from './requests/removeInviteRequest';
import { removeAcceptedInviteRequest } from './requests/removeAcceptedInviteRequest';

const INVITE_ACCESS_TARGETS = {
  read: 'Read',
  write: 'Write'
}

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
  }

  const onInviteRemove = async (uuid) => {
    const result = await removeInviteRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, invites: pageState.invites.filter((item) => item.uuid !== uuid) });
  }

  const onAcceptedInviteRemove = async (uuid) => {
    const result = await removeAcceptedInviteRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, acceptedInvites: pageState.acceptedInvites.filter((item) => item.uuid !== uuid) });
  }

  const onApiAccessTokenCreate = async () => {
    const result = await createApiAccessTokenRequest();

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, apiAccessTokens: pageState.apiAccessTokens.concat(result.result) });
  }

  const onApiAccessTokenRemove = async (id) => {
    const result = await removeApiAccessTokenRequest(id);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, apiAccessTokens: pageState.apiAccessTokens.filter((item) => item.uuid !== id) })
  }

  return (
    <>
      <div class="box mb-4 p-8">
        <h2 class="mb-2">Privacy</h2>
        <p class="mb-6 light-color">In this block you can create access tokens for PullKeeper's API. For getting list of available enpoints you can check <a href="/api-docs/index.html" class="simple-link">API documentation</a>.</p>
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-end">
          <Show
            when={pageState.apiAccessTokens.length > 0}
            fallback={<p>You didn't specify any API access tokens yet.</p>}
          >
            <div class="table-wrapper w-fit">
              <table class="table">
                <tbody>
                  <For each={pageState.apiAccessTokens}>
                    {(apiAccessToken) =>
                      <tr>
                        <td>{apiAccessToken.value}</td>
                        <td class="!min-w-0">
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
            </div>
          </Show>
          <p class="flex lg:justify-center mt-6 lg:mt-0">
            <button
              class="btn-primary btn-small"
              onClick={onApiAccessTokenCreate}
            >Create API access token</button>
          </p>
        </div>
        <p class="mt-8 mb-6 light-color">In this block you can specify coowners of your account.</p>
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-end">
          <div>
            <Show when={pageState.acceptedInvites.length > 0}>
              <h3 class="mb-2 font-medium">Accepted invites</h3>
              <div class="table-wrapper w-fit">
                <table class="table">
                  <tbody>
                    <For each={pageState.acceptedInvites}>
                      {(invite) =>
                        <tr>
                          <td>{invite.email}</td>
                          <td class="!min-w-20 text-center">{INVITE_ACCESS_TARGETS[invite.access]}</td>
                          <td class="!min-w-0">
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
              <h3 class="mb-2 font-medium">Sent invites</h3>
              <div class="table-wrapper w-fit">
                <table class="table">
                  <tbody>
                    <For each={pageState.invites}>
                      {(invite) =>
                        <tr>
                          <td>{invite.email}</td>
                          <td class="!min-w-20 text-center">{INVITE_ACCESS_TARGETS[invite.access]}</td>
                          <td class="!min-w-0">
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
              </div>
            </Show>
          </div>
          <p class="flex lg:justify-center mt-6 lg:mt-0">
            <button
              class="btn-primary btn-small"
              onClick={openModal}
            >Invite coowner</button>
          </p>
        </div>
      </div>
      <Modal>
        <div class="flex flex-col items-center">
          <h1 class="mb-2">New invite</h1>
          <p class="mb-8 text-center">Invite will be send to email and after submitting such person will have access to your account.</p>
          <section class="inline-block w-4/5">
            <Select
              required
              labelText="Access level"
              classList="w-full mb-8"
              items={INVITE_ACCESS_TARGETS}
              selectedValue={formStore.access}
              onSelect={(value) => setFormStore('access', value)}
            />
            <FormInputField
              required
              labelText="Invite email"
              classList="w-full"
              value={formStore.email}
              onChange={(value) => setFormStore('email', value)}
            />
            <div class="flex">
              <button class="btn-primary mt-8 mx-auto" onClick={onInviteCreate}>Save</button>
            </div>
          </section>
        </div>
      </Modal>
      <Flash />
    </>
  );
}
