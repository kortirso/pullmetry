import { Portal } from 'solid-js/web';
import { createSignal, Show, children } from 'solid-js';

import { Close } from '../../assets';
import { clickOutside } from '../../helpers';

export const createModal = () => {
  const [isOpen, setIsOpen] = createSignal(false);

  return {
    openModal() {
      setIsOpen(true);
    },
    closeModal() {
      setIsOpen(false);
    },
    Modal(props) {
      const safeChildren = children(() => props.children);

      return (
        <Portal>
          <Show when={isOpen()}>
            <div class="fixed top-0 left-0 w-full h-full z-40 bg-eerie-black/75 flex items-center justify-center">
              <div class="modal" use:clickOutside={() => setIsOpen(false)}>
                <div>
                  <button
                    class="absolute top-4 right-4"
                    onClick={() => setIsOpen(false)}
                  >
                    <Close />
                  </button>
                  {safeChildren()}
                </div>
              </div>
            </div>
          </Show>
        </Portal>
      );
    }
  }
}
