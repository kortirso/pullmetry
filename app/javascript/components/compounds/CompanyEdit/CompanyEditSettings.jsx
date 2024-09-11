import { createStore } from 'solid-js/store';

import { FormInputField, Dropdown, Select, createFlash } from '../../molecules';

import { updateWorkTimeRequest } from '../Profile/requests/updateWorkTimeRequest';

const TIME_ZONES = {
  '-12': 'GMT-12', '-11': 'GMT-11', '-10': 'GMT-10', '-9': 'GMT-9',
  '-8': 'GMT-8', '-7': 'GMT-7', '-6': 'GMT-6', '-5': 'GMT-5',
  '-4': 'GMT-4', '-3': 'GMT-3', '-2': 'GMT-2', '-1': 'GMT-1',
  '0': 'GMT+0', '1': 'GMT+1', '2': 'GMT+2', '3': 'GMT+3',
  '4': 'GMT+4', '5': 'GMT+5', '6': 'GMT+6', '7': 'GMT+7',
  '8': 'GMT+8', '9': 'GMT+9', '10': 'GMT+10', '11': 'GMT+11',
  '12': 'GMT+12'
}

export const CompanyEditSettings = (props) => {
  /* eslint-disable solid/reactivity */
  const [formStore, setFormStore] = createStore({
    startsAt: props.startsAt,
    endsAt: props.endsAt,
    timezone: props.timezone
  });
  /* eslint-enable solid/reactivity */

  const { Flash, renderErrors, renderNotices } = createFlash();

  const UpdateSettings = async () => {
    const result = await updateWorkTimeRequest({ ...formStore, companyId: props.companyUuid });

    if (result.errors) renderErrors(result.errors);
    else renderNotices(['Work time is saved']);
  }

  return (
    <>
      <Dropdown title="Company settings">
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8">
            <div class="grid lg:grid-cols-3 lg:gap-8">
              <div class="flex-1">
                <FormInputField
                  required
                  classList="w-full"
                  labelText="Work start time"
                  placeholder="09:00"
                  value={formStore.startsAt}
                  onChange={(value) => setFormStore('startsAt', value)}
                />
              </div>
              <div class="flex-1">
                <FormInputField
                  required
                  classList="w-full"
                  labelText="Work end time"
                  placeholder="18:00"
                  value={formStore.endsAt}
                  onChange={(value) => setFormStore('endsAt', value)}
                />
              </div>
              <div class="flex-1">
                <Select
                  required
                  classList="w-full"
                  labelText="Work time zone"
                  items={TIME_ZONES}
                  selectedValue={formStore.timezone}
                  onSelect={(value) => setFormStore('timezone', value)}
                />
              </div>
            </div>
            <div>
              <p>You can select working time of your company. This allows better calculations of average review time, because it will not count not-working time and weekends.</p>
            </div>
          </div>
          <button class="btn-primary btn-small mt-8 lg:mt-4 mb-2" onClick={UpdateSettings}>Update company settings</button>
        </div>
      </Dropdown>
      <Flash />
    </>
  )
};

