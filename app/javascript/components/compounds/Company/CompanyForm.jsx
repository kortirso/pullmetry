import { createSignal } from 'solid-js';

import { createModal } from '../../atoms';
import { FormInputField } from '../../molecules';

import { createCompanyRequest } from './requests/createCompanyRequest';

export const CompanyForm = (props) => {
  const { Modal, openModal, closeModal } = createModal();

  const [pageState, setPageState] = createSignal({
    title: '',
    errors: []
  });

  const onSubmit = async () => {
    if (pageState().title.length === 0) {
      setPageState({ ...pageState(), errors: ['Title is required'] });
      return;
    }

    const result = createCompanyRequest({ title: pageState().title, user_uuid: props.accountUuid });

    if (result.errors) setPageState({ ...pageState(), errors: result.errors })
    else window.location = result.redirect_path;
  };

  return (
    <>
      <button className="btn-primary hidden sm:block" onClick={openModal}>Create company</button>
      <button className="btn-primary sm:hidden" onClick={openModal}>+</button>
      <Modal>
        <h1 className="mb-8">New Company</h1>
        <p className="mb-4">Company is just abstraction for collection of repositories belongs to one group with similar settings</p>
        <section className="inline-block w-full">
          <FormInputField
            required
            placeholder="Company's title"
            labelText="Title"
            onChange={(value) => setPageState({ ...pageState(), title: value })}
          />
          {pageState().errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState().errors[0]}</p>
          ) : null}
          <button className="btn-primary mt-4" onClick={onSubmit}>Save company</button>
        </section>
      </Modal>
    </>
  );
};
