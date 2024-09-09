import { For } from 'solid-js';

export const Flash = (props) => (
  <div class="fixed top-8 right-8">
    <For each={props.errors}>
      {(error, index) =>
        <div
          class="relative mb-2 py-4 pl-8 pr-12 rounded bg-orange-300 border border-orange-400"
        >
          <p>{error}</p>
          <span
            class="absolute top-1 right-1 cursor-pointer p-1"
            onClick={() => props.onCloseError(index())}
          >x</span>
        </div>
      }
    </For>
  </div>
)
