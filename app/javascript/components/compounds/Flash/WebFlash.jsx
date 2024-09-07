import { createSignal, createEffect, createMemo, Show } from 'solid-js';

export const WebFlash = (props) => {
  // message is [type, value] or []
  // eslint-disable-next-line solid/reactivity
  const [message, setMessage] = createSignal(props.value.length > 0 ? props.value[0] : []);

  createEffect(() => setTimeout(() => setMessage([]), 3000));

  const messageType = createMemo(() => message()[0]);
  const messageValue = createMemo(() => message()[1]);

  const closeMessage = () => setMessage([]);

  return (
    <div class="fixed top-8 right-8">
      <Show when={message().length > 0}>
        <div
          class='relative mb-2 py-4 pl-8 pr-12 rounded border'
          classList={{ 'bg-orange-300 border-orange-400': messageType() === 'alert', 'bg-green-300 border-green-400': messageType() === 'notice' }}
        >
          <p>{messageValue()}</p>
          <span
            class="absolute top-1 right-1 cursor-pointer p-1"
            onClick={closeMessage}
          >x</span>
        </div>
      </Show>
    </div>
  );
}
