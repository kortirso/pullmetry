import { createStore } from 'solid-js/store';

import { Feedback } from '../../../assets';
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
        <span><Feedback /></span>
        <span>Feedback</span>
      </button>
      <Modal>
        <div class="flex flex-col items-center">
          <h1 class="mb-2">New feedback</h1>
          <p class="mb-8 text-center">You can directly send your question/feedback/bug report to <a href="mailto:kortirso@gmail.com" class="simple-link">email</a>, to <a href="https://t.me/kortirso" target="_blank" rel="noopener noreferrer" class="simple-link">Telegram</a> or just leave here.</p>
          <section class="inline-block w-4/5">
            <FormInputField
              labelText="Title"
              classList="w-full mb-8"
              value={formStore.title}
              onChange={(value) => setFormStore('title', value)}
            />
            <FormDescriptionField
              required
              labelText="Description"
              classList="w-full mb-8"
              value={formStore.description}
              onChange={(value) => setFormStore('description', value)}
            />
            <div class="form-field mb-8">
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
              classList="w-full"
              placeholder={props.email}
              value={formStore.email}
              onChange={(value) => setFormStore('email', value)}
            />
            <div class="flex">
              <button class="btn-primary mt-8 mx-auto" onClick={onSubmit}>Send feedback</button>
            </div>
          </section>
        </div>
      </Modal>
      <Flash />
    </>
  );
}
