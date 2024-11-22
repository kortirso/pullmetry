export const Arrow = (props) => (
  <svg
    width="14"
    height="14"
    viewBox="0 0 11 11"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    class={props.rotated ? 'transition-transform rotate-180' : 'transition-transform rotate-0'}
  >
    <path
      d="M3.2373 4.30505L5.7102 6.77795L8.1831 4.30505"
      stroke={props.active ? "#FBA346" : "#18191F"}
      stroke-width="0.824283"
      stroke-linecap="round"
      stroke-linejoin="round"
    />
  </svg>
);
