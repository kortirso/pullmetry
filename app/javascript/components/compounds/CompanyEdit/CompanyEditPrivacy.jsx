import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Checkbox, Flash } from '../../atoms';
import { FormInputField, Dropdown, createModal, Select } from '../../molecules';

import { createInviteRequest } from '../Profile/requests/createInviteRequest';
import { removeInviteRequest } from '../Profile/requests/removeInviteRequest';
import { removeAcceptedInviteRequest } from '../Profile/requests/removeAcceptedInviteRequest';
import { updateCompanyConfigurationRequest } from './requests/updateCompanyConfigurationRequest';

const INVITE_ACCESS_TARGETS = {
  read: 'Read',
  write: 'Write'
};

export const CompanyEditPrivacy = (props) => {
  const [pageState, setPageState] = createStore({
    // eslint-disable-next-line solid/reactivity
    acceptedInvites: props.acceptedInvites,
    // eslint-disable-next-line solid/reactivity
    invites: props.invites,
    // eslint-disable-next-line solid/reactivity
    private: props.private,
    errors: []
  });

  const [formStore, setFormStore] = createStore({
    email: '',
    access: 'read'
  });

  const { Modal, openModal, closeModal } = createModal();

  const onCloseError = (errorIndex) => {
    setPageState('errors', pageState.errors.slice().filter((item, index) => index !== errorIndex));
  }

  const togglePrivate = async () => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { private: !pageState.private });

    if (result.errors) setPageState('errors', result.errors);
    else {
      setPageState({
        ...pageState,
        private: !pageState.private,
        errors: []
      });
    }
  }

  const onInviteCreate = async () => {
    const result = await createInviteRequest({ invite: formStore, companyId: props.companyUuid });

    if (result.errors) setPageState('errors', result.errors);
    else {
      batch(() => {
        setPageState({
          ...pageState,
          invites: pageState.invites.concat(result.result),
          errors: []
        });
        setFormStore({ email: '', access: 'read' });
        closeModal();
      });
    }
  }

  const onInviteRemove = async (uuid) => {
    const result = await removeInviteRequest(uuid);

    if (result.errors) setPageState('errors', result.errors);
    else setPageState({
      ...pageState,
      invites: pageState.invites.filter((item) => item.uuid !== uuid),
      errors: []
    });
  }

  const onAcceptedInviteRemove = async (uuid) => {
    const result = await removeAcceptedInviteRequest(uuid);

    if (result.errors) setPageState('errors', result.errors);
    else setPageState({
      ...pageState,
      acceptedInvites: pageState.acceptedInvites.filter((item) => item.uuid !== uuid),
      errors: []
    });
  }

  return (
    <>
      <Dropdown title="Privacy">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8 mb-8">
            <div>
              <Checkbox
                left
                labelText="Private"
                value={pageState.private}
                onToggle={togglePrivate}
              />
            </div>
            <div>
              <p>If this configuration enabled then company's developers can't have access to insights. If disabled - developers will see insights immediately after login. Access permissions will change after the next synchronization.</p>
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
                        <p class="flex-1">{invite.invitesEmail}</p>
                        <p class="w-20">{INVITE_ACCESS_TARGETS[invite.access]}</p>
                        <p
                          class="btn-danger btn-xs ml-8"
                          onClick={() => onAcceptedInviteRemove(invite.uuid)}
                        >X</p>
                      </div>
                    }
                  </For>
                </div>
              </Show>
              <Show
                when={pageState.invites.length > 0}
                fallback={<p>There are no not answered invites.</p>}
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
              >Invite coworker</p>
            </div>
            <div>
              <p>In this block you can specify coworkers from company that don't have insights but it requires for them to see statistics.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Flash errors={pageState.errors} onCloseError={onCloseError} />
      <Modal>
        <h1 class="mb-8">New invite</h1>
        <p class="mb-4">Invite will be send to email and after submitting such person will have access to company insights.</p>
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
          <button class="btn-primary mt-4" onClick={onInviteCreate}>Create invite</button>
        </section>
      </Modal>
    </>
  );
}

