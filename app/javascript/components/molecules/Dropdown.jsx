import { createSignal, Show, children } from 'solid-js';

import { Chevron } from '../../assets';

export const Dropdown = (props) => {
  const safeChildren = children(() => props.children);

  const [isOpen, setIsOpen] = createSignal(false);

  const toggle = () => setIsOpen(!isOpen());  

  return (
    <div class="bg-white border-b border-gray-200">
      <div
        class="cursor-pointer py-6 px-8 flex justify-between items-center"
        onClick={toggle}
      >
        <h2 class="m-0 text-xl">{props.title}</h2>
        <Chevron rotated={isOpen()} />
      </div>
      <Show when={isOpen()}>
        {safeChildren}
      </Show>
    </div>
  );
}
