import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, createFlash, createModal } from '../../molecules';
import { objectKeysToCamelCase } from '../../../helpers';

import { updateCompanyConfigurationRequest } from './requests/updateCompanyConfigurationRequest';
import { createIgnoreRequest } from './requests/createIgnoreRequest';
import { removeIgnoreRequest } from './requests/removeIgnoreRequest';
import { removeExcludeGroupRequest } from './requests/removeExcludeGroupRequest';

const TARGETS = {
  'title': 'Title',
  'description': 'Description',
  'branch_name': 'Branch name',
  'destination_branch_name': 'Destination branch name'
}

const CONDITIONS = {
  'equal': 'is equal',
  'not_equal': 'is not equal',
  'contain': 'contains',
  'not_contain': 'does not contain'
}

export const CompanyEditPullRequests = (props) => {
  /* eslint-disable solid/reactivity */
  const [pageState, setPageState] = createStore({
    defaultFetchPeriod: props.fetchPeriod,
    fetchPeriod: props.fetchPeriod,
    ignores: props.ignores,
    excludesGroups: props.excludesGroups
  });
  /* eslint-enable solid/reactivity */

  const [ignoreFormStore, setIgnoreFormStore] = createStore({
    entityValue: ''
  });

  const { Modal, openModal, closeModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const updateFetchPeriod = async () => {
    const result = await updateCompanyConfigurationRequest(props.companyId, { fetch_period: parseInt(pageState.fetchPeriod) });

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, defaultFetchPeriod: pageState.fetchPeriod });
  }

  const resetFetchPeriod = () => setPageState({ ...pageState, fetchPeriod: pageState.defaultFetchPeriod });

  const onIgnoreCreate = async () => {
    const result = await createIgnoreRequest({ entityIgnore: ignoreFormStore, companyId: props.companyId });

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        setPageState({ ...pageState, ignores: pageState.ignores.concat(objectKeysToCamelCase(result.result)) });
        setIgnoreFormStore({ entityValue: '' });
        closeModal();
      });
    }
  }

  const onIgnoreRemove = async (id) => {
    const result = await removeIgnoreRequest(id);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, ignores: pageState.ignores.filter((item) => item.id !== id) });
  }

  const onExcludeGroupRemove = async (id) => {
    const result = await removeExcludeGroupRequest(id);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, excludesGroups: pageState.excludesGroups.filter((item) => item.id !== id) });
  }

  return (
    <>
      <div class="box mb-4 p-8">
        <h2 class="mb-6">Fetching pull requests</h2>
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
        <p class="mt-10 mb-2 light-color">In this block you can specify ignoring pull requests while fetching by some condition.</p>
        <p class="mb-6 light-color">Pull request will be excluded from processing if all rules in any group match.</p>
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-end">
          <Show
            when={pageState.excludesGroups.length > 0}
            fallback={<p>There are no exclude rules yet.</p>}
          >
            <div class="table-wrapper w-fit">
              <table class="table">
                <tbody>
                  <For each={pageState.excludesGroups}>
                    {(excludeGroup) =>
                      <tr>
                        <td>
                          <For each={excludeGroup.excludesRules}>
                            {(excludesRule) =>
                              <p>
                                <span class="mr-4">{TARGETS[excludesRule.target]}</span>
                                <span class="mr-4">{CONDITIONS[excludesRule.condition]}</span>
                                <span>{excludesRule.value}</span>
                              </p>
                            }
                          </For>
                        </td>
                        <td class="!min-w-0">
                          <p
                            class="btn-danger btn-xs"
                            onClick={() => onExcludeGroupRemove(excludeGroup.id)}
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
            >Add exclude rules</button>
          </p>
        </div>
        <p class="mt-10 mb-6 light-color">In this block you can specify ignoring developers/bots while fetching pull requests data.</p>
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
                            onClick={() => onIgnoreRemove(ignore.id)}
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
