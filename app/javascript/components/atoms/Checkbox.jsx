import { Show } from 'solid-js';

export const Checkbox = (props) => (
  <div class="flex items-center">
    <Show when={props.labelText && props.left}>
      <label
        class="mr-2 cursor-pointer"
        onClick={() => props.disabled ? null : props.onToggle()}
      >{props.labelText}</label>
    </Show>
    <div class="toggle" onClick={() => props.disabled ? null : props.onToggle()}>
      <input
        checked={props.value}
        disabled={props.disabled}
        class="toggle-checkbox"
        type="checkbox"
      />
      <label class="toggle-label" />
    </div>
    <Show when={props.labelText && props.right}>
      <label
        class="ml-2 cursor-pointer"
        onClick={() => props.disabled ? null : props.onToggle()}
      >{props.labelText}</label>
    </Show>
  </div>
)
