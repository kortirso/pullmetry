import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, createFlash, createModal } from '../../molecules';
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
    const result = await createIgnoreRequest({ entityIgnore: ignoreFormStore, companyId: props.companyUuid });

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        setPageState({ ...pageState, ignores: pageState.ignores.concat(objectKeysToCamelCase(result.result)) });
        setIgnoreFormStore({ entityValue: '' });
        closeModal();
      });
    }
  }

  const onIgnoreRemove = async (uuid) => {
    const result = await removeIgnoreRequest(uuid);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, ignores: pageState.ignores.filter((item) => item.uuid !== uuid) });
  }

  return (
    <>
      <div class="box mb-4 p-8">
        <h2 class="mb-2">Fetching pull requests</h2>
        <p class="mb-6 light-color">You can set fetch period for collecting data of pull requests. For regular accounts - maximum 30 days, for premium - 90 days. By default fetch period is 30 days. So if 30 is enough for you - you can skip this attribute.</p>
        <FormInputField
          confirmable
          classList="w-1/3 lg:w-1/5"
          labelText="Fetch period (days)"
          placeholder="30"
          defaultValue={pageState.defaultFetchPeriod}
          value={pageState.fetchPeriod}
          onChange={(value) => setPageState('fetchPeriod', value)}
          onConfirm={updateFetchPeriod}
          onCancel={resetFetchPeriod}
        />
        <p class="my-6 light-color">In this block you can specify ignoring developers/bots while fetching pull requests data.</p>
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-end">
          <Show
            when={pageState.ignores.length > 0}
            fallback={<p>There are no ignores yet.</p>}
          >
            <div class="table-wrapper w-fit">
              <table class="table">
                <tbody>
                  <For each={pageState.ignores}>
                    {(ignore) =>
                      <tr>
                        <td>{ignore.entityValue}</td>
                        <td class="!min-w-0">
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
            </div>
          </Show>
          <p class="flex lg:justify-center mt-6 lg:mt-0">
            <button
              class="btn-primary btn-small"
              onClick={openModal}
            >Add ignore</button>
          </p>
        </div>
      </div>
      <Modal>
        <div class="flex flex-col items-center">
          <h1 class="mb-2">New ignore</h1>
          <p class="mb-8 text-center">Pull requests, comments, reviews of specified developer or bot will be ignored.</p>
          <section class="inline-block w-4/5">
            <FormInputField
              required
              classList="w-full"
              labelText="Ignore entity"
              value={ignoreFormStore.entityValue}
              onChange={(value) => setIgnoreFormStore('entityValue', value)}
            />
          </section>
          <div class="flex">
            <button class="btn-primary mt-8 mx-auto" onClick={onIgnoreCreate}>Save</button>
          </div>
        </div>
      </Modal>
      <Flash />
    </>
  );
}
