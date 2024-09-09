import { createStore } from 'solid-js/store';

import { FormInputField, Dropdown } from '../../molecules';

import { transferCompanyRequest } from './requests/transferCompanyRequest';

export const CompanyEditTransfer = (props) => {
  const [formStore, setFormStore] = createStore({
    userUuid: ''
  });

  const onSubmit = async () => {
    const result = await transferCompanyRequest(props.companyUuid, formStore);

    console.log(result);
  }

  return (
    <Dropdown title="Transfer">
      <div class="py-6 px-8">
        <div class="grid lg:grid-cols-2 gap-8 mb-2">
          <div>
            <FormInputField
              required
              placeholder="d878353f-892c-4650-8cc7-0810a2ec461a"
              labelText="Target user's UUID"
              value={formStore.userUuid}
              onChange={(value) => setFormStore('userUuid', value)}
            />
            <button class="btn-primary btn-danger mt-4" onClick={onSubmit}>Transfer</button>
          </div>
          <div>
            <p class="mb-4">You can transfer company's ownership to another user. If such user is allowed to create new companies then ownership will be transfered.</p>
            <p>You just need to specify another user's uuid. This action is not revertable.</p>
          </div>
        </div>
      </div>
    </Dropdown>
  );
}
