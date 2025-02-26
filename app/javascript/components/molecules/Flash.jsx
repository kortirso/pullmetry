import { createSignal, Show, For } from 'solid-js';

export const createFlash = () => {
  const [messages, setMessages] = createSignal([]);

  const closeMessage = (messageIndex) => {
    setMessages(
      messages().slice().filter((item, index) => index !== messageIndex)
    );
  }

  return {
    renderErrors(values) {
      setMessages(
        values.map((item) => { return { type: 'error', value: item } })
      );
    },
    renderNotices(values) {
      setMessages(
        values.map((item) => { return { type: 'notice', value: item } })
      );
    },
    Flash() {
      return (
        <Show when={messages().length > 0}>
          <div class="fixed top-8 right-8 z-50">
            <For each={messages()}>
              {(message, index) =>
                <div
                  class="relative mb-2 py-4 pl-8 pr-12 rounded-lg"
                  classList={{ 'bg-yellow-orange text-white': message.type === 'error', 'bg-iceberg text-white': message.type === 'notice' }}
                >
                  <p>{message.value}</p>
                  <span
                    class="absolute top-1 right-1 cursor-pointer p-1"
                    onClick={() => closeMessage(index())}
                  >x</span>
                </div>
              }
            </For>
          </div>
        </Show>
      );
    }
  }
}
