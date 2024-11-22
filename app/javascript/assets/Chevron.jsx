export const Chevron = (props) => (
  <svg
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    class={props.rotated ? 'transition-transform rotate-0' : 'transition-transform rotate-180'}
  >
    <g clip-path="url(#clip0_44_281)">
      <path d="M7.41 15.41L12 10.83L16.59 15.41L18 14L12 8L6 14L7.41 15.41Z" fill="#63B3CE" />
    </g>
    <defs>
      <clipPath id="clip0_44_281">
        <rect width="24" height="24" fill="white" />
      </clipPath>
    </defs>
  </svg>
);
