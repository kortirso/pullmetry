import { createSignal, Show, For } from 'solid-js';

import { FormLabel } from '../atoms';
import { Chevron } from '../../assets';
import { clickOutside } from '../../helpers';

export const Select = (props) => {
  const [isOpen, setIsOpen] = createSignal(false);

  const onSelect = (value) => {
    props.onSelect(value);
    setIsOpen(false);
  }

  return (
    <div class="form-field relative cursor-pointer" use:clickOutside={() => setIsOpen(false)}>
      <Show when={props.labelText}>
        <FormLabel required={props.required} value={props.labelText} />
      </Show>
      <div class="form-field">
        <div class="form-value flex justify-between items-center text-sm" onClick={() => setIsOpen(!isOpen())}>
          {props.selectedValue ? props.items[props.selectedValue] : ''}
          <Chevron rotated={isOpen()} />
        </div>
        <Show when={isOpen()}>
          <ul class="form-dropdown">
            <For each={Object.entries(props.items)}>
              {([key, value]) =>
                <li
                  class="bg-white hover:bg-gray-200 py-2 px-3 text-sm"
                  onClick={() => onSelect(key)}
                >
                  {value}
                </li>
              }
            </For>
          </ul>
        </Show>
      </div>
    </div>
  );
}
