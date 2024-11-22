import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, createModal, createFlash } from '../../molecules';
import { convertDate, objectKeysToCamelCase } from '../../../helpers';

import { createVacationRequest } from './requests/createVacationRequest'
import { removeVacationRequest } from './requests/removeVacationRequest'

export const ProfileVacations = (props) => {
  /* eslint-disable solid/reactivity */
  const [pageState, setPageState] = createStore({
    vacations: props.vacations
  });
  /* eslint-enable solid/reactivity */

  const [formStore, setFormStore] = createStore({
    startTime: '',
    endTime: ''
  });

  const { Modal, openModal, closeModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const onVacationCreate = async () => {
    const result = await createVacationRequest(formStore);

    if (result.errors) renderErrors(result.errors);
    else {
      batch(() => {
        setPageState({ ...pageState, vacations: pageState.vacations.concat(objectKeysToCamelCase(result.result)) });
        setFormStore({ startTime: '', endTime: '' });
        closeModal();
      });
    }
  }

  const onVacationRemove = async (id) => {
    const result = await removeVacationRequest(id);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, vacations: pageState.vacations.filter((item) => item.id !== id) });
  }

  return (
    <>
      <div class="box mb-4 p-8">
        <h2 class="mb-2">Vacations</h2>
        <p class="mb-6 light-color">Here you can specify your vacations, and for any of your company this time will be reduced from time spending for reviews for better calculating average times.</p>
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-end">
          <Show
            when={pageState.vacations.length > 0}
            fallback={<p>You didn't specify any vacations yet.</p>}
          >
            <div class="table-wrapper w-fit">
              <table class="table">
                <tbody>
                  <For each={pageState.vacations}>
                    {(vacation) =>
                      <tr>
                        <td>{convertDate(vacation.startTime)} - {convertDate(vacation.endTime)}</td>
                        <td class="!min-w-0">
                          <p
                            class="btn-danger btn-xs"
                            onClick={() => onVacationRemove(vacation.id)}
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
            >Add vacation</button>
          </p>
        </div>
      </div>
      <Modal>
        <div class="flex flex-col items-center">
          <h1 class="mb-2">New vacation</h1>
          <p class="mb-8 text-center">Format of time can be 2023-01-01, 01-01-2023 or 01.01.2023.</p>
          <section class="grid lg:grid-cols-2 lg:gap-8 w-full">
            <FormInputField
              required
              classList="w-full"
              labelText="Start date"
              placeholder="2023-01-01"
              value={formStore.startTime}
              onChange={(value) => setFormStore('startTime', value)}
            />
            <FormInputField
              required
              classList="w-full"
              labelText="End date"
              placeholder="2023-01-02"
              value={formStore.endTime}
              onChange={(value) => setFormStore('endTime', value)}
            />
          </section>
          <div class="flex">
            <button class="btn-primary mt-8 mx-auto" onClick={onVacationCreate}>Save</button>
          </div>
        </div>
      </Modal>
      <Flash />
    </>
  );
}

