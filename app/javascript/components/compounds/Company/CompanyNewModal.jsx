import { CompanyForm } from '../../../components';
import { createModal, createFlash } from '../../molecules';

import { createCompanyRequest } from './requests/createCompanyRequest';

export const CompanyNewModal = (props) => {
  const { Modal, openModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const onSubmit = async (formStore) => {
    if (formStore.errors) {
      renderErrors(formStore.errors);
      return;
    }

    const result = await createCompanyRequest({ ...formStore, userUuid: props.accountUuid });

    if (result.errors) renderErrors(result.errors);
    else window.location = '/companies';
  }

  return (
    <>
      <button class="btn-primary hidden sm:block" onClick={openModal}>Create company</button>
      <button class="btn-primary sm:hidden" onClick={openModal}>+</button>
      <Modal>
        <div class="flex flex-col items-center">
          <h1 class="mb-2">New Company</h1>
          <p class="mb-8 text-center">Company is just abstraction for collection of repositories belongs to one group with similar settings</p>
          <CompanyForm onSubmit={onSubmit} />
        </div>
      </Modal>
      <Flash />
    </>
  );
}
