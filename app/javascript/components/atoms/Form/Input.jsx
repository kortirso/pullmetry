import { Show } from 'solid-js';

export const FormInput = (props) => (
  <div class="flex items-center">
    <input
      class={[props.classList, 'form-value'].join(' ')}
      required={props.required}
      disabled={props.disabled}
      placeholder={props.placeholder}
      value={props.value}
      onInput={(e) => props.onChange ? props.onChange(e.target.value) : null}
    />
    <Show when={props.confirmable && props.defaultValue !== props.value}>
      <button
        class="btn-primary btn-small btn-success ml-0.5"
        onClick={() => props.onConfirm()}
      >+</button>
      <button
        class="btn-primary btn-small"
        onClick={() => props.onCancel()}
      >-</button>
    </Show>
  </div>
)
