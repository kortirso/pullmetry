import { Show } from 'solid-js';

import { FormLabel, FormInput } from '../atoms';

export const FormInputField = (props) => (
  <div class="form-field">
    <Show when={props.labelText}>
      <FormLabel required={props.required} value={props.labelText} />
    </Show>
    <FormInput
      required={props.required}
      disabled={props.disabled}
      placeholder={props.placeholder}
      value={props.value}
      onChange={(value) => props.onChange ? props.onChange(value) : null}
    />
  </div>
)
