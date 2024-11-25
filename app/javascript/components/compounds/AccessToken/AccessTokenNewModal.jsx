import { AccessTokenForm } from '../../../components';
import { createModal, createFlash } from '../../molecules';
import { Key } from '../../../assets';

import { createAccessTokenRequest } from './requests/createAccessTokenRequest';

export const AccessTokenNewModal = (props) => {
  const { Modal, openModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const onSubmit = async (formStore) => {
    if (formStore.errors) {
      renderErrors(formStore.errors);
      return;
    }

    const result = await createAccessTokenRequest({ payload: formStore, uuid: props.uuid, tokenable: props.tokenable });

    if (result.errors) renderErrors(result.errors);
    else window.location.reload();
  }

  return (
    <>
      <span
        class="mr-2 cursor-pointer"
        classList={{ ['p-0.5 bg-yellow-orange rounded-lg text-white']: props.required }}
        title="Click to add access token"
        onClick={openModal}
      >
        <Key />
      </span>
      <Modal>
        <div class="flex flex-col items-center">
          <h1 class="mb-2">New access token</h1>
          <p class="mb-8 text-center">
            Visit <a href="/access_tokens" target="_blank" rel="noopener noreferrer" class="simple-link">help page</a> with guide for creating access token at Github/Gitlab and add it here.
          </p>
          <AccessTokenForm onSubmit={onSubmit} />
        </div>
      </Modal>
      <Flash />
    </>
  );
}
