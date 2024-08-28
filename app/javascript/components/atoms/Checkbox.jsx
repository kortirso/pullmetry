import { Show } from 'solid-js';

export const Checkbox = (props) => (
  <div class="flex items-center" onClick={() => props.onToggle()}>
    <Show when={props.labelText && props.left}>
      <label class="mr-2 cursor-pointer">{props.labelText}</label>
    </Show>
    <div class="toggle">
      <input
        checked={props.value}
        disabled={props.disabled}
        class="toggle-checkbox"
        type="checkbox"
      />
      <label class="toggle-label" />
    </div>
    <Show when={props.labelText && props.right}>
      <label class="ml-2 cursor-pointer">{props.labelText}</label>
    </Show>
  </div>
);
