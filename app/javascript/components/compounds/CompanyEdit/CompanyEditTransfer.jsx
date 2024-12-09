import { createStore } from 'solid-js/store';

import { FormInputField, createFlash } from '../../molecules';

import { transferCompanyRequest } from './requests/transferCompanyRequest';

export const CompanyEditTransfer = (props) => {
  const [formStore, setFormStore] = createStore({
    userId: ''
  });

  const { Flash, renderErrors } = createFlash();

  const onSubmit = async () => {
    const result = await transferCompanyRequest(props.companyId, formStore);

    if (result.errors) renderErrors(result.errors);
    else window.location = result.redirect_path;
  }

  return (
    <>
      <div class="box p-8">
        <h2 class="mb-6">Transfer</h2>
        <p class="mb-6 light-color">You can transfer company's ownership to another user. If such user is allowed to create new companies then ownership will be transfered. You just need to specify another user's ID. This action is not revertable.</p>
        <div>
          <FormInputField
            required
            classList="w-full lg:w-1/2"
            placeholder="d878353f-892c-4650-8cc7-0810a2ec461a"
            labelText="Target user's ID"
            value={formStore.userId}
            onChange={(value) => setFormStore('userId', value)}
          />
          <button class="btn-danger mt-6 btn-small" onClick={onSubmit}>Transfer</button>
        </div>
      </div>
      <Flash />
    </>
  );
}
