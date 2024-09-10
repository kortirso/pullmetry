import { Show, For, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, Dropdown, createModal, createFlash } from '../../molecules';
import { convertDate } from '../../../helpers';

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
        setPageState({ ...pageState, vacations: pageState.vacations.concat(result.result) });
        setFormStore({ startTime: '', endTime: '' });
        closeModal();
      });
    }
  };

  const onVacationRemove = async (id) => {
    const result = await removeVacationRequest(id);

    if (result.errors) renderErrors(result.errors);
    else setPageState({ ...pageState, vacations: pageState.vacations.filter((item) => item.id !== id) })
  };

  return (
    <>
      <Dropdown title="Vacations">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8 mb-2">
            <div>
              <Show
                when={pageState.vacations.length > 0}
                fallback={<p>You didn't specify any vacations yet.</p>}
              >
                <div class="zebra-list">
                  <For each={pageState.vacations}>
                    {(vacation) =>
                      <div class="zebra-list-element">
                        <p>{convertDate(vacation.startTime)} - {convertDate(vacation.endTime)}</p>
                        <p
                          class="btn-danger btn-xs"
                          onClick={() => onVacationRemove(vacation.id)}
                        >X</p>
                      </div>
                    }
                  </For>
                </div>
              </Show>
              <p
                class="btn-primary btn-small mt-4"
                onClick={openModal}
              >Add vacation</p>
            </div>
            <div>
              <p>Here you can specify your vacations, and for any of your company this time will be reduced from time spending for reviews for better calculating average times.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Modal>
        <h1 class="mb-8">New vacation</h1>
        <p class="mb-4">Format of time can be 2023-01-01, 01-01-2023 or 01.01.2023.</p>
        <section class="inline-block w-full">
          <FormInputField
            required
            labelText="Start date"
            value={formStore.startTime}
            onChange={(value) => setFormStore('startTime', value)}
          />
          <FormInputField
            required
            labelText="End date"
            value={formStore.endTime}
            onChange={(value) => setFormStore('endTime', value)}
          />
          <button class="btn-primary mt-4" onClick={onVacationCreate}>Save vacation</button>
        </section>
      </Modal>
      <Flash />
    </>
  )
};

