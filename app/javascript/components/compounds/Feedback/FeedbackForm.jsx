import { createSignal, Show, batch } from 'solid-js';
import { createStore } from 'solid-js/store';

import { createModal, Checkbox } from '../../atoms';
import { FormInputField, FormDescriptionField } from '../../molecules';

import { createFeedbackRequest } from './requests/createFeedbackRequest';

export const FeedbackForm = (props) => {
  const { Modal, openModal, closeModal } = createModal();

  const [formErrors, setFormErrors] = createSignal([]);

  const [formStore, setFormStore] = createStore({
    title: '',
    description: '',
    answerable: false,
    email: ''
  });

  const onSubmit = async () => {
    if (formStore.description.length === 0) {
      setFormErrors(['Description is required']);
      return;
    }

    const result = createFeedbackRequest(formStore);

    if (result.errors) setFormErrors(result.errors);
    else {
      batch(() => {
        setFormStore('title', '');
        setFormStore('description', '');
        setFormStore('answerable', false);
        setFormStore('email', '');
        setFormErrors([]);
        closeModal();
      });
    };
  };

  return (
    <>
      <button class={`cursor-pointer ${props.classList}`} onClick={openModal}>Feedback</button>
      <Modal>
        <h1 class="mb-8">New feedback</h1>
        <p class="mb-4">You can directly send your question/feedback/bug report to <a href="mailto:kortirso@gmail.com" class="simple-link">email</a>, to <a href="https://t.me/kortirso" target="_blank" rel="noopener noreferrer" class="simple-link">Telegram</a> or just leave here.</p>
        <section class="inline-block w-full">
          <FormInputField
            labelText="Title"
            onChange={(value) => setFormStore('title', value)}
          />
          <FormDescriptionField
            required
            labelText="Description"
            onChange={(value) => setFormStore('description', value)}
          />
          <div class="form-field">
            <Checkbox
              left
              labelText="Can answer by email?"
              value={formStore.answerable}
              onToggle={() => setFormStore('answerable', !formStore.answerable)}
            />
          </div>
          <FormInputField
            disabled={!formStore.answerable}
            labelText="Email for answer"
            placeholder={props.email}
            onChange={(value) => setFormStore('email', value)}
          />
          <Show when={formErrors().length > 0}>
            <p class="text-sm text-orange-600">{formErrors()[0]}</p>
          </Show>
          <button class="btn-primary mt-4" onClick={onSubmit}>Send feedback</button>
        </section>
      </Modal>
    </>
  );
};
