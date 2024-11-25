import { createStore } from 'solid-js/store';

import { FormInputField } from '../../molecules';

export const AccessTokenForm = (props) => {
  const submitText = () => props.submitText || 'Save';

  const [formStore, setFormStore] = createStore({
    value: '',
    expiredAt: ''
  });

  const submitForm = async () => {
    if (formStore.value.length === 0) {
      return props.onSubmit({ errors: ['Value is required'] });
    }

    return props.onSubmit(formStore);
  }

  return (
    <section class="inline-block w-4/5">
      <FormInputField
        required
        placeholder="github_pat_****_******"
        labelText="Value"
        classList="w-full mb-8"
        value={formStore.value}
        onChange={(value) => setFormStore('value', value)}
      />
      <FormInputField
        placeholder="2024-01-31 13:35"
        labelText="Expiration time"
        classList="w-full"
        value={formStore.expiredAt}
        onChange={(value) => setFormStore('expiredAt', value)}
      />
      <div class="flex">
        <button class="btn-primary mt-8 mx-auto" onClick={submitForm}>{submitText()}</button>
      </div>
    </section>
  );
}
