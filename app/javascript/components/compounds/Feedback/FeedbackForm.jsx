import { createStore } from 'solid-js/store';

import { Checkbox } from '../../atoms';
import { FormInputField, FormDescriptionField, createModal, createFlash } from '../../molecules';

import { createFeedbackRequest } from './requests/createFeedbackRequest';

export const FeedbackForm = (props) => {
  const { Modal, openModal, closeModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const [formStore, setFormStore] = createStore({
    title: '',
    description: '',
    answerable: false,
    email: ''
  });

  const onSubmit = async () => {
    if (formStore.description.length === 0) {
      renderErrors(['Description is required']);
      return;
    }

    const result = createFeedbackRequest(formStore);

    if (result.errors) renderErrors(result.errors);
    else {
      setFormStore({ title: '', description: '', answerable: false, email: '' })
      closeModal();
    }
  }

  return (
    <>
      <button
        class={[props.classList, 'cursor-pointer'].join(' ')}
        onClick={openModal}
      >
        <span innerHTML={props.svg} />
        <span>Feedback</span>
      </button>
      <Modal>
        <h1 class="mb-8">New feedback</h1>
        <p class="mb-4">You can directly send your question/feedback/bug report to <a href="mailto:kortirso@gmail.com" class="simple-link">email</a>, to <a href="https://t.me/kortirso" target="_blank" rel="noopener noreferrer" class="simple-link">Telegram</a> or just leave here.</p>
        <section class="inline-block w-full">
          <FormInputField
            labelText="Title"
            value={formStore.title}
            onChange={(value) => setFormStore('title', value)}
          />
          <FormDescriptionField
            required
            labelText="Description"
            value={formStore.description}
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
            value={formStore.email}
            onChange={(value) => setFormStore('email', value)}
          />
          <button class="btn-primary mt-4" onClick={onSubmit}>Send feedback</button>
        </section>
      </Modal>
      <Flash />
    </>
  );
}
