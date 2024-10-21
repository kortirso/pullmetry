import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, Dropdown, createFlash, createModal } from '../../molecules';
import { objectKeysToCamelCase } from '../../../helpers';

import { updateCompanyConfigurationRequest } from './requests/updateCompanyConfigurationRequest';
import { createIgnoreRequest } from './requests/createIgnoreRequest';
import { removeIgnoreRequest } from './requests/removeIgnoreRequest';

export const CompanyEditPullRequests = (props) => {
  /* eslint-disable solid/reactivity */
  const [pageState, setPageState] = createStore({
    defaultFetchPeriod: props.fetchPeriod,
    fetchPeriod: props.fetchPeriod,
    ignores: props.ignores
  });
  /* eslint-enable solid/reactivity */

  const [ignoreFormStore, setIgnoreFormStore] = createStore({
    entityValue: ''
  });

  const { Modal, openModal, closeModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const updateFetchPeriod = async () => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { fetch_period: parseInt(pageState.fetchPeriod) });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, defaultFetchPeriod: pageState.fetchPeriod });
  }

  const resetFetchPeriod = () => setPageState({ ...pageState, fetchPeriod: pageState.defaultFetchPeriod });

  const onIgnoreCreate = async () => {
    const result = await createIgnoreRequest({ ignore: ignoreFormStore, companyId: props.companyUuid });

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        setPageState({ ...pageState, ignores: pageState.ignores.concat(objectKeysToCamelCase(result.result)) });
        setIgnoreFormStore({ entityValue: '' });
        closeModal();
      });
    }
  };

  const onIgnoreRemove = async (uuid) => {
    const result = await removeIgnoreRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, ignores: pageState.ignores.filter((item) => item.uuid !== uuid) });
  }

  return (
    <>
      <Dropdown title="Fetching pull requests">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8 mb-8 pb-8 border-b border-gray-200">
            <div>
              <FormInputField
                confirmable
                classList="w-1/2"
                labelText="Fetch period (days)"
                placeholder="30"
                defaultValue={pageState.defaultFetchPeriod}
                value={pageState.fetchPeriod}
                onChange={(value) => setPageState('fetchPeriod', value)}
                onConfirm={updateFetchPeriod}
                onCancel={resetFetchPeriod}
              />
            </div>
            <div>
              <p>You can set fetch period for collecting data of pull requests. For regular accounts - maximum 30 days, for premium - 60 days.</p>
              <p class="mt-2">By default fetch period is 30 days. So if 30 is enough for you - you can skip this attribute.</p>
            </div>
          </div>
          <div class="grid lg:grid-cols-2 gap-8 mb-2">
            <div>
              <Show
                when={pageState.ignores.length > 0}
                fallback={<p>There are no ignores yet.</p>}
              >
                <p class="mb-2 font-medium">Ignores</p>
                <table class="table zebra w-full">
                  <tbody>
                    <For each={pageState.ignores}>
                      {(ignore) =>
                        <tr>
                          <td>{ignore.entityValue}</td>
                          <td class="w-12">
                            <p
                              class="btn-danger btn-xs"
                              onClick={() => onIgnoreRemove(ignore.uuid)}
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
              >Add ignore</p>
            </div>
            <div>
              <p>In this block you can specify ignoring developers/bots while fetching pull requests data.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Modal>
        <h1 class="mb-8">New ignore</h1>
        <p class="mb-4">Pull requests, comments, reviews of specified entity will be ignored.</p>
        <section class="inline-block w-full">
          <FormInputField
            required
            classList="w-full lg:w-3/4"
            labelText="Ignore entity"
            value={ignoreFormStore.entityValue}
            onChange={(value) => setIgnoreFormStore('entityValue', value)}
          />
          <button class="btn-primary mt-4" onClick={onIgnoreCreate}>Save ignore</button>
        </section>
      </Modal>
      <Flash />
    </>
  );
}
