import { createSignal, Show } from 'solid-js';
import { createStore } from 'solid-js/store';

import { createModal, Select } from '../../atoms';
import { FormInputField } from '../../molecules';

import { createRepositoryRequest } from './requests/createRepositoryRequest';

export const RepositoryForm = (props) => {
  const { Modal, openModal } = createModal();

  const [formErrors, setFormErrors] = createSignal([]);

  const [formStore, setFormStore] = createStore({
    // eslint-disable-next-line solid/reactivity
    companyUuid: props.companyUuid || Object.keys(props.companies)[0],
    title: '',
    link: '',
    // eslint-disable-next-line solid/reactivity
    provider: Object.keys(props.providers)[0],
    externalId: ''
  });

  const onSubmit = async () => {
    if (formStore.title.length === 0) {
      setFormErrors(['Title is required']);
      return;
    }

    if (formStore.link.length === 0) {
      setFormErrors(['Link is required']);
      return;
    }

    if (formStore.provider === 'gitlab') {
      setFormErrors(['External ID is required']);
      return;
    }

    const result = await createRepositoryRequest(formStore);

    if (result.errors) setFormErrors(result.errors);
    else window.location = result.redirect_path;
  };

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
          <Show when={formErrors().length > 0}>
            <p class="text-sm text-orange-600">{formErrors()[0]}</p>
          </Show>
          <button class="btn-primary mt-4" onClick={onSubmit}>Save repository</button>
        </section>
      </Modal>
    </>
  );
};
