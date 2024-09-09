import { createStore } from 'solid-js/store';

import { FormInputField, Dropdown, Select } from '../../molecules';

import { updateProfileRequest } from './requests/updateProfileRequest';

const TIME_ZONES = {
  '-12': 'GMT-12', '-11': 'GMT-11', '-10': 'GMT-10', '-9': 'GMT-9',
  '-8': 'GMT-8', '-7': 'GMT-7', '-6': 'GMT-6', '-5': 'GMT-5',
  '-4': 'GMT-4', '-3': 'GMT-3', '-2': 'GMT-2', '-1': 'GMT-1',
  '0': 'GMT+0', '1': 'GMT+1', '2': 'GMT+2', '3': 'GMT+3',
  '4': 'GMT+4', '5': 'GMT+5', '6': 'GMT+6', '7': 'GMT+7',
  '8': 'GMT+8', '9': 'GMT+9', '10': 'GMT+10', '11': 'GMT+11',
  '12': 'GMT+12'
}

export const ProfileSettings = (props) => {
  const [formStore, setFormStore] = createStore({
    // eslint-disable-next-line solid/reactivity
    startTime: props.startTime,
    // eslint-disable-next-line solid/reactivity
    endTime: props.endTime,
    // eslint-disable-next-line solid/reactivity
    timeZone: props.timeZone
  });

  const UpdateSettings = async () => {
    const result = await updateProfileRequest(formStore);

    if (result.redirect_path) window.location = result.redirect_path;
  };

  return (
    <Dropdown title="User settings">
      <div class="py-6 px-8">
        <div class="grid lg:grid-cols-2 gap-8">
          <div>
            <div class="grid grid-cols-3 gap-8 mt-4">
              <div class="flex-1">
                <FormInputField
                  required
                  labelText="Work start time"
                  placeholder="09:00"
                  value={formStore.startTime}
                  onChange={(value) => setFormStore('startTime', value)}
                />
              </div>
              <div class="flex-1">
                <FormInputField
                  required
                  labelText="Work end time"
                  placeholder="18:00"
                  value={formStore.endTime}
                  onChange={(value) => setFormStore('endTime', value)}
                />
              </div>
              <div class="flex-1">
                <Select
                  required
                  labelText="Work time zone"
                  items={TIME_ZONES}
                  selectedValue={formStore.timeZone}
                  onSelect={(value) => setFormStore('timeZone', value)}
                />
              </div>
            </div>
          </div>
          <div>
            <p>You can select your working time. This allows better calculations of average review time, because it will not count not-working time and weekends. Company can use it's own worktime configuration.</p>
          </div>
        </div>
        <button class="btn-primary btn-small mt-4 mb-2" onClick={UpdateSettings}>Update user settings</button>
      </div>
    </Dropdown>
  )
};

