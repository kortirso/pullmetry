import { Portal } from 'solid-js/web';
import { createSignal, Show } from 'solid-js';

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
      return (
        <Portal>
          <Show when={isOpen()}>
            <div class="fixed top-0 left-0 w-full h-full z-50 bg-stone-700/75 flex items-center justify-center">
              <div class="modal">
                <div class="modal-content">
                  <button
                    class="btn-primary btn-small absolute top-4 right-4 px-3 rounded z-10"
                    onClick={() => setIsOpen(false)}
                  >
                    X
                  </button>
                  {props.children}
                </div>
              </div>
            </div>
          </Show>
        </Portal>
      );
    },
  };
}
