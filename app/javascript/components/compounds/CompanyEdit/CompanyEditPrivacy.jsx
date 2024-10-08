import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Checkbox } from '../../atoms';
import { FormInputField, Dropdown, createModal, Select, createFlash } from '../../molecules';

import { createInviteRequest } from '../Profile/requests/createInviteRequest';
import { removeInviteRequest } from '../Profile/requests/removeInviteRequest';
import { removeAcceptedInviteRequest } from '../Profile/requests/removeAcceptedInviteRequest';
import { updateCompanyConfigurationRequest } from './requests/updateCompanyConfigurationRequest';

const INVITE_ACCESS_TARGETS = {
  read: 'Read',
  write: 'Write'
};

export const CompanyEditPrivacy = (props) => {
  /* eslint-disable solid/reactivity */
  const [pageState, setPageState] = createStore({
    acceptedInvites: props.acceptedInvites,
    invites: props.invites,
    private: props.private
  });
  /* eslint-enable solid/reactivity */

  const [formStore, setFormStore] = createStore({
    email: '',
    access: 'read'
  });

  const { Modal, openModal, closeModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const togglePrivate = async () => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { private: !pageState.private });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, private: !pageState.private });
  }

  const onInviteCreate = async () => {
    const result = await createInviteRequest({ invite: formStore, companyId: props.companyUuid });

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

  return (
    <>
      <Dropdown title="Privacy">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8 mb-8 pb-8 border-b border-gray-200">
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
                <div class="mb-8">
                  <p class="mb-2 font-medium">Accepted invites</p>
                  <table class="table zebra w-full">
                    <tbody>
                      <For each={pageState.acceptedInvites}>
                        {(invite) =>
                          <tr>
                            <td>{invite.invitesEmail}</td>
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
              >Invite coworker</p>
            </div>
            <div>
              <p>In this block you can specify coworkers from company that don't have insights but it requires for them to see statistics.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Modal>
        <h1 class="mb-8">New invite</h1>
        <p class="mb-4">Invite will be send to email and after submitting such person will have access to company insights.</p>
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
  );
}

