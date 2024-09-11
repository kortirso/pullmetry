import { Show } from 'solid-js';

export const FormLabel = (props) => (
  <label class="form-label">
    {props.value}
    <Show when={props.required}>
      <sup class="leading-4">*</sup>
    </Show>
  </label>
)
