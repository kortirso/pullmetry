import { Show } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, createModal, Select, createFlash } from '../../molecules';

import { createRepositoryRequest } from './requests/createRepositoryRequest';

export const RepositoryForm = (props) => {
  /* eslint-disable solid/reactivity */
  const [formStore, setFormStore] = createStore({
    companyUuid: props.companyUuid || Object.keys(props.companies)[0],
    title: '',
    link: '',
    provider: Object.keys(props.providers)[0],
    externalId: ''
  });
  /* eslint-enable solid/reactivity */

  const { Modal, openModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const onSubmit = async () => {
    if (formStore.title.length === 0) {
      renderErrors(['Title is required']);
      return;
    }

    if (formStore.link.length === 0) {
      renderErrors(['Link is required']);
      return;
    }

    if (formStore.provider === 'gitlab') {
      renderErrors(['External ID is required']);
      return;
    }

    const result = await createRepositoryRequest(formStore);

    if (result.errors) renderErrors(result.errors);
    else window.location = result.redirect_path;
  }

  return (
    <>
      <button class="btn-primary hidden sm:block" onClick={openModal}>Create repository</button>
      <button class="btn-primary sm:hidden" onClick={openModal}>+</button>
      <Modal>
        <h1 class="mb-8">New Repository</h1>
        <p class="mb-4">Repository is just abstraction of your real repository. Link must be real, title - anything you want.</p>
        <section class="inline-block w-full">
          <Show when={Object.keys(props.companies).length > 1}>
            <Select
              required
              labelText="Company"
              items={props.companies}
              selectedValue={formStore.companyUuid}
              onSelect={(value) => setFormStore('companyUuid', value)}
            />
          </Show>
          <FormInputField
            required
            placeholder="Repository's title"
            labelText="Title"
            value={formStore.title}
            onChange={(value) => setFormStore('title', value)}
          />
          <FormInputField
            required
            placeholder="https://github.com/company_name/repo_name"
            labelText="Link"
            value={formStore.link}
            onChange={(value) => setFormStore('link', value)}
          />
          <Select
            required
            labelText="Provider"
            items={props.providers}
            selectedValue={formStore.provider}
            onSelect={(value) => setFormStore('provider', value)}
          />
          <FormInputField
            labelText="External id"
            value={formStore.externalId}
            onChange={(value) => setFormStore('externalId', value)}
          />
          <button class="btn-primary mt-4" onClick={onSubmit}>Save repository</button>
        </section>
      </Modal>
      <Flash />
    </>
  );
}
