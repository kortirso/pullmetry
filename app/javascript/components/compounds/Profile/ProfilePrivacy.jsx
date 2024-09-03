import { createSignal, Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Dropdown, createModal, Select } from '../../atoms';
import { FormInputField } from '../../molecules';

import { createApiAccessTokenRequest } from './requests/createApiAccessTokenRequest';
import { createInviteRequest } from './requests/createInviteRequest';
import { removeApiAccessTokenRequest } from './requests/removeApiAccessTokenRequest';
import { removeInviteRequest } from './requests/removeInviteRequest';


const INVITE_ACCESS_TARGETS = {
  read: 'Read',
  write: 'Write'
};

export const ProfilePrivacy = (props) => {
  const [pageState, setPageState] = createStore({
    // eslint-disable-next-line solid/reactivity
    acceptedInvites: props.acceptedInvites,
    // eslint-disable-next-line solid/reactivity
    invites: props.invites,
    // eslint-disable-next-line solid/reactivity
    apiAccessTokens: props.apiAccessTokens,
    errors: []
  });

  const [formErrors, setFormErrors] = createSignal([]);

  const [formStore, setFormStore] = createStore({
    email: '',
    access: 'read'
  });

  const { Modal, openModal, closeModal } = createModal();

  const onInviteCreate = async () => {
    const result = await createInviteRequest(formStore);

    if (result.errors) setFormErrors(result.errors);
    else {
      batch(() => {
        setPageState({
          ...pageState,
          invites: pageState.invites.concat(result.result)
        });
        setFormErrors([]);
        setFormStore({ email: '', access: 'read' });
        closeModal();
      });
    }
  };

  const onInviteRemove = async (uuid) => {
    const result = await removeInviteRequest(uuid);

    if (result.errors) setPageState('errors', result.errors);
    else setPageState({
      ...pageState,
      invites: pageState.invites.filter((item) => item.uuid !== uuid),
      errors: []
    })
  };

  const onApiAccessTokenCreate = async () => {
    const result = await createApiAccessTokenRequest();

    if (result.errors) setPageState('errors', result.errors);
    else setPageState({
      ...pageState,
      apiAccessTokens: pageState.apiAccessTokens.concat(result.result),
      errors: []
    })
  };

  const onApiAccessTokenRemove = async (id) => {
    const result = await removeApiAccessTokenRequest(id);

    if (result.errors) setPageState('errors', result.errors);
    else setPageState({
      ...pageState,
      apiAccessTokens: pageState.apiAccessTokens.filter((item) => item.uuid !== id),
      errors: []
    })
  };

  return (
    <>
      <Dropdown title="Privacy">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8 mb-8">
            <div>
              <Show
                when={pageState.apiAccessTokens.length > 0}
                fallback={<p>You didn't specify any API access tokens yet.</p>}
              >
                <div class="zebra-list">
                  <For each={pageState.apiAccessTokens}>
                    {(apiAccessToken) =>
                      <div class="zebra-list-element">
                        <p>{apiAccessToken.value}</p>
                        <p
                          class="btn-danger btn-xs"
                          onClick={() => onApiAccessTokenRemove(apiAccessToken.uuid)}
                        >X</p>
                      </div>
                    }
                  </For>
                </div>
              </Show>
              <p
                class="btn-primary btn-small mt-4"
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
                <div class="zebra-list pb-4 mb-4 border-b border-gray-200">
                  <p class="mb-2 font-medium">Accepted invites</p>
                  <For each={pageState.acceptedInvites}>
                    {(invite) =>
                      <div class="zebra-list-element">
                        <p class="flex-1">{invite.email}</p>
                        <p class="w-20">{INVITE_ACCESS_TARGETS[invite.access]}</p>
                        <p
                          class="btn-danger btn-xs ml-8"
                          onClick={() => onInviteRemove(invite.uuid)}
                        >X</p>
                      </div>
                    }
                  </For>
                </div>
              </Show>
              <Show
                when={pageState.invites.length > 0}
                fallback={<p>You didn't specify any invites yet.</p>}
              >
                <div class="zebra-list">
                  <p class="mb-2 font-medium">Sent invites</p>
                  <For each={pageState.invites}>
                    {(invite) =>
                      <div class="zebra-list-element">
                        <p class="flex-1">{invite.email}</p>
                        <p class="w-20">{INVITE_ACCESS_TARGETS[invite.access]}</p>
                        <p
                          class="btn-danger btn-xs ml-8"
                          onClick={() => onInviteRemove(invite.uuid)}
                        >X</p>
                      </div>
                    }
                  </For>
                </div>
              </Show>
              <p
                class="btn-primary btn-small mt-4"
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
            labelText="Invite email"
            value={formStore.email}
            onChange={(value) => setFormStore('email', value)}
          />
          <Select
            required
            labelText="Access level"
            items={INVITE_ACCESS_TARGETS}
            selectedValue={formStore.access}
            onSelect={(value) => setFormStore('access', value)}
          />
          <Show when={formErrors().length > 0}>
            <p class="text-sm text-orange-600">{formErrors()[0]}</p>
          </Show>
          <button class="btn-primary mt-4" onClick={onInviteCreate}>Create invite</button>
        </section>
      </Modal>
    </>
  )
};

