import { Show } from 'solid-js';
import { createStore } from 'solid-js/store';

import { FormInputField, Select } from '../../molecules';

export const RepositoryForm = (props) => {
  const submitText = () => props.submitText || 'Save';

  /* eslint-disable solid/reactivity */
  const [formStore, setFormStore] = createStore({
    companyUuid: props.companyUuid || Object.keys(props.companies)[0],
    title: '',
    link: '',
    provider: Object.keys(props.providers)[0],
    externalId: ''
  });
  /* eslint-enable solid/reactivity */

  const submitForm = async () => {
    if (formStore.title.length === 0) {
      return props.onSubmit({ errors: ['Title is required'] });
    }

    if (formStore.link.length === 0) {
      return props.onSubmit({ errors: ['Link is required'] });
    }

    if (formStore.provider === 'gitlab' && formStore.externalId.length === 0) {
      return props.onSubmit({ errors: ['External ID is required for Gitlab'] });
    }

    return props.onSubmit(formStore);
  }

  return (
    <section class="inline-block w-4/5">
      <Show when={Object.keys(props.companies).length > 1}>
        <Select
          required
          labelText="Company"
          classList="w-full mb-8"
          items={props.companies}
          selectedValue={formStore.companyUuid}
          onSelect={(value) => setFormStore('companyUuid', value)}
        />
      </Show>
      <FormInputField
        required
        placeholder="Repository's title"
        labelText="Title"
        classList="w-full mb-8"
        value={formStore.title}
        onChange={(value) => setFormStore('title', value)}
      />
      <Select
        required
        labelText="Provider"
        classList="w-full mb-8"
        items={props.providers}
        selectedValue={formStore.provider}
        onSelect={(value) => setFormStore('provider', value)}
      />
      <FormInputField
        required
        placeholder="https://github.com/company_name/repo_name"
        labelText="Link"
        classList={`w-full ${formStore.provider === 'gitlab' ? 'mb-8' : ''}`}
        value={formStore.link}
        onChange={(value) => setFormStore('link', value)}
      />
      <Show when={formStore.provider === 'gitlab'}>
        <FormInputField
          labelText="External ID"
          placeholder="External ID"
          classList="w-full"
          value={formStore.externalId}
          onChange={(value) => setFormStore('externalId', value)}
        />
      </Show>
      <div class="flex">
        <button class="btn-primary mt-8 mx-auto" onClick={submitForm}>{submitText()}</button>
      </div>
    </section>
  );
}
