import { RepositoryForm } from '../../../components';
import { createModal, createFlash } from '../../molecules';

import { createRepositoryRequest } from './requests/createRepositoryRequest';

export const RepositoryNewModal = (props) => {
  const { Modal, openModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const onSubmit = async (formStore) => {
    if (formStore.errors) {
      renderErrors(formStore.errors);
      return;
    }

    const result = await createRepositoryRequest(formStore);

    if (result.errors) renderErrors(result.errors);
    else window.location.reload();
  }

  return (
    <>
      <button class="btn-primary hidden sm:block" onClick={openModal}>Create repository</button>
      <button class="btn-primary sm:hidden" onClick={openModal}>+</button>
      <Modal>
        <div class="flex flex-col items-center">
          <h1 class="mb-2">New Repository</h1>
          <p class="mb-8 text-center">Repository is just abstraction of your real repository. Link must be real, title - anything you want.</p>
          <RepositoryForm
            companyUuid={props.companyUuid}
            companies={props.companies}
            providers={props.providers}
            onSubmit={onSubmit}
          />
        </div>
      </Modal>
      <Flash />
    </>
  );
}
