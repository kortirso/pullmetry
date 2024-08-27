import { createSignal } from 'solid-js';

import { createModal, Checkbox } from '../../atoms';
import { FormInputField, FormDescriptionField } from '../../molecules';

import { createFeedbackRequest } from './requests/createFeedbackRequest';

export const FeedbackForm = (props) => {
  const { Modal, openModal, closeModal } = createModal();

  const [pageState, setPageState] = createSignal({
    title: '',
    description: '',
    answerable: false,
    email: '',
    errors: []
  });

  const onSubmit = async () => {
    if (pageState().description.length === 0) {
      setPageState({ ...pageState(), errors: ['Description is required'] });
      return;
    }

    const result = createFeedbackRequest({
      title: pageState().title,
      description: pageState().description,
      answerable: pageState().answerable,
      email: pageState().email
    });

    if (result.errors) setPageState({ ...pageState(), errors: result.errors })
    else setPageState({ title: '', description: '', answerable: false, email: '', errors: [] });

    closeModal();
  };

  return (
    <>
      <button class={`cursor-pointer ${props.class_list}`} onClick={openModal}>Feedback</button>
      <Modal>
        <h1 class="mb-8">New feedback</h1>
        <p class="mb-4">You can directly send your question/feedback/bug report to <a href="mailto:kortirso@gmail.com" class="simple-link">email</a>, to <a href="https://t.me/kortirso" target="_blank" rel="noopener noreferrer" class="simple-link">Telegram</a> or just leave here.</p>
        <section class="inline-block w-full">
          <FormInputField
            labelText="Title"
            onChange={(value) => setPageState({ ...pageState(), title: value })}
          />
          <FormDescriptionField
            required
            labelText="Title"
            onChange={(value) => setPageState({ ...pageState(), description: value })}
          />
          <div class="form-field">
            <Checkbox
              left
              labelText="Can answer by email?"
              value={pageState().answerable}
              onToggle={() => setPageState({ ...pageState(), answerable: !pageState().answerable })}
            />
          </div>
          <FormInputField
            disabled={!pageState().answerable}
            labelText="Email for answer"
            placeholder={props.email}
            onChange={(value) => setPageState({ ...pageState(), email: value })}
          />
          {pageState().errors.length > 0 ? (
            <p class="text-sm text-orange-600">{pageState().errors[0]}</p>
          ) : null}
          <button class="btn-primary mt-4" onClick={onSubmit}>Send feedback</button>
        </section>
      </Modal>
    </>
  );
};
