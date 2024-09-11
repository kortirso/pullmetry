import { Show } from 'solid-js';

import { FormLabel, FormTextArea } from '../atoms';

export const FormDescriptionField = (props) => (
  <div class="form-field">
    <Show when={props.labelText}>
      <FormLabel required={props.required} value={props.labelText} />
    </Show>
    <FormTextArea
      required={props.required}
      value={props.value}
      onChange={(value) => props.onChange ? props.onChange(value) : null}
    />
  </div>
)
