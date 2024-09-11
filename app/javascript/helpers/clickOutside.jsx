import { onCleanup } from 'solid-js';

export const clickOutside = (el, accessor) => {
  const onClick = (e) => !el.contains(e.target) && accessor()?.();
  document.body.addEventListener('click', onClick);

  onCleanup(() => document.body.removeEventListener('click', onClick));
}
