import { createStore } from 'solid-js/store';

import { FormInputField, createModal, createFlash } from '../../molecules';

import { createCompanyRequest } from './requests/createCompanyRequest';

export const CompanyForm = (props) => {
  const { Modal, openModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const [formStore, setFormStore] = createStore({
    title: ''
  });

  const onSubmit = async () => {
    if (formStore.title.length === 0) {
      renderErrors(['Title is required']);
      return;
    }

    const result = await createCompanyRequest({ ...formStore, userUuid: props.accountUuid });

    if (result.errors) renderErrors(result.errors);
    else window.location = result.redirect_path;
  }

  return (
    <>
      <button class="btn-primary hidden sm:block" onClick={openModal}>Create company</button>
      <button class="btn-primary sm:hidden" onClick={openModal}>+</button>
      <Modal>
        <h1 class="mb-8">New Company</h1>
        <p class="mb-4">Company is just abstraction for collection of repositories belongs to one group with similar settings</p>
        <section class="inline-block w-full">
          <FormInputField
            required
            placeholder="Company's title"
            labelText="Title"
            value={formStore.title}
            onChange={(value) => setFormStore('title', value)}
          />
          <button class="btn-primary mt-4" onClick={onSubmit}>Save company</button>
        </section>
      </Modal>
      <Flash />
    </>
  );
}
