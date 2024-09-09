import { createStore } from 'solid-js/store';

import { Flash } from '../../atoms';
import { FormInputField, Dropdown } from '../../molecules';

import { updateCompanyConfigurationRequest } from './requests/updateCompanyConfigurationRequest';

export const CompanyEditPullRequests = (props) => {
  const [pageState, setPageState] = createStore({
    // eslint-disable-next-line solid/reactivity
    defaultFetchPeriod: props.fetchPeriod,
    // eslint-disable-next-line solid/reactivity
    fetchPeriod: props.fetchPeriod,
    errors: []
  });

  const onCloseError = (errorIndex) => {
    setPageState('errors', pageState.errors.slice().filter((item, index) => index !== errorIndex));
  }

  const updateFetchPeriod = async () => {
    const result = await updateCompanyConfigurationRequest(props.companyUuid, { fetchPeriod: pageState.fetchPeriod });

    if (result.errors) setPageState({ ...pageState, errors: result.errors });
    else {
      setPageState({
        ...pageState,
        defaultFetchPeriod: pageState.fetchPeriod,
        errors: []
      });
    }
  }

  const resetFetchPeriod = () => setPageState({ ...pageState, fetchPeriod: pageState.defaultFetchPeriod, errors: [] });

  return (
    <>
      <Dropdown title="Fetching pull requests">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8 mb-8">
            <div>
              <FormInputField
                confirmable
                labelText="Fetch period (days)"
                placeholder="30"
                defaultValue={pageState.defaultFetchPeriod}
                value={pageState.fetchPeriod}
                onChange={(value) => setPageState('fetchPeriod', value)}
                onConfirm={updateFetchPeriod}
                onCancel={resetFetchPeriod}
              />
            </div>
            <div>
              <p>You can set fetch period for collecting data of pull requests. For regular accounts - maximum 30 days, for premium - 60 days.</p>
              <p class="mt-2">By default fetch period is 30 days. So if 30 is enough for you - you can skip this attribute.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Flash errors={pageState.errors} onCloseError={onCloseError} />
    </>
  );
}
