import { Show, splitProps } from 'solid-js';

import { FormLabel, FormInput } from '../atoms';

export const FormInputField = (props) => {
  const [labelProps, formInputProps] = splitProps(props, ['labelText']);

  return (
    <div class="form-field">
      <Show when={labelProps.labelText}>
        <FormLabel required={props.required} value={labelProps.labelText} />
      </Show>
      <FormInput { ...formInputProps } />
    </div>
  );
}
