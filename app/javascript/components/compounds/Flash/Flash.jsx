import { createSignal, createEffect, For } from 'solid-js';

export const Flash = (props) => {
  const [messages, setMessages] = createSignal([]);

  createEffect(() => setTimeout(() => setMessages([]), 3000));

  return (
    <div class="fixed top-8 right-8">
      <For each={messages()}>
        {(message) =>
          <div
            class="relative mb-2 py-4 pl-8 pr-12 rounded bg-orange-300 border border-orange-400"
          >
            <p>{message}</p>
            <span
              class="absolute top-1 right-1 cursor-pointer p-1"
            >x</span>
          </div>
        }
      </For>
    </div>
  );
}
