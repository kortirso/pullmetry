import { Show } from 'solid-js';

export const FormInput = (props) => (
  <div class="flex">
    <input
      class={[props.classList, 'form-value'].join(' ')}
      required={props.required}
      disabled={props.disabled}
      placeholder={props.placeholder}
      value={props.value}
      onInput={(e) => props.onChange ? props.onChange(e.target.value) : null}
    />
    <Show when={props.confirmable && props.defaultValue !== props.value}>
      <div class="flex items-end">
        <button
          class="btn-primary btn-small mx-0.5"
          onClick={() => props.onConfirm()}
        >Save</button>
        <button
          class="btn-primary btn-small"
          onClick={() => props.onCancel()}
        >Cancel</button>
      </div>
    </Show>
  </div>
)
