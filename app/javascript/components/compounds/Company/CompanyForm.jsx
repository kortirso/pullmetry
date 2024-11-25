import { createStore } from 'solid-js/store';

import { FormInputField } from '../../molecules';

export const CompanyForm = (props) => {
  const submitText = () => props.submitText || 'Save';

  const [formStore, setFormStore] = createStore({
    title: ''
  });

  const submitForm = async () => {
    if (formStore.title.length === 0) {
      return props.onSubmit({ errors: ['Title is required'] });
    }

    return props.onSubmit(formStore);
  }

  return (
    <section class="inline-block w-4/5">
      <FormInputField
        required
        placeholder="Company's title"
        labelText="Title"
        classList="w-full"
        value={formStore.title}
        onChange={(value) => setFormStore('title', value)}
      />
      <div class="flex">
        <button class="btn-primary mt-8 mx-auto" onClick={submitForm}>{submitText()}</button>
      </div>
    </section>
  );
}
