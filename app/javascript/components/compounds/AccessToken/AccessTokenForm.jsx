import { createStore } from 'solid-js/store';

import { FormInputField, createModal, createFlash } from '../../molecules';
import { Key } from '../../../assets';

import { createAccessTokenRequest } from './requests/createAccessTokenRequest';

export const AccessTokenForm = (props) => {
  const { Modal, openModal } = createModal();
  const { Flash, renderErrors } = createFlash();

  const [formStore, setFormStore] = createStore({
    value: '',
    expiredAt: ''
  });

  const onSubmit = async () => {
    if (formStore.value.length === 0) {
      renderErrors(['Value is required']);
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
              <button class="btn-primary mt-8 mx-auto" onClick={onSubmit}>Save</button>
            </div>
          </section>
        </div>
      </Modal>
      <Flash />
    </>
  );
}
