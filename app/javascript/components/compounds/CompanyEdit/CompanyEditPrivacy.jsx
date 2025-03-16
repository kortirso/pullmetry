import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { Checkbox } from '../../atoms';
import { FormInputField, createModal, Select, createFlash } from '../../molecules';

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
    const result = await updateCompanyConfigurationRequest(props.companyId, { private: !pageState.private });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, private: !pageState.private });
  }

  const onInviteCreate = async () => {
    const result = await createInviteRequest({ invite: formStore, companyId: props.companyId });

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        setPageState({ ...pageState, invites: pageState.invites.concat(result.result) });
        setFormStore({ email: '', access: 'read' });
        closeModal();
      });
    }
  }

  const onInviteRemove = async (id) => {
    const result = await removeInviteRequest(id);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, invites: pageState.invites.filter((item) => item.id !== id) });
  }

  const onAcceptedInviteRemove = async (id) => {
    const result = await removeAcceptedInviteRequest(id);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, acceptedInvites: pageState.acceptedInvites.filter((item) => item.id !== id) });
  }

  return (
    <>
      <div class="box mb-4 p-8">
        <h2 class="mb-6">Privacy</h2>
        <p class="mb-6 light-color">If this configuration enabled then company's developers can't have access to insights. If disabled - developers will see insights immediately after login. Access permissions will be changed after the next synchronization.</p>
        <Checkbox
          left
          labelText="Private"
          value={pageState.private}
          onToggle={togglePrivate}
        />
        <p class="mt-10 mb-6 light-color">In this block you can specify coworkers from company that don't have insights but it requires for them to see statistics.</p>
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
                              onClick={() => onAcceptedInviteRemove(invite.id)}
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
                              onClick={() => onInviteRemove(invite.id)}
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
          <p class="mb-8 text-center">Invite will be send to email and after submitting such person will have access to company insights.</p>
          <section class="inline-block w-4/5">
            <Select
              required
              classList="w-full mb-8"
              labelText="Access level"
              items={INVITE_ACCESS_TARGETS}
              selectedValue={formStore.access}
              onSelect={(value) => setFormStore('access', value)}
            />
            <FormInputField
              required
              classList="w-full"
              labelText="Invite email"
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

