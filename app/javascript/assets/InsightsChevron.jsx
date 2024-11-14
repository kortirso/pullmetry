export const InsightsChevron = (props) => (
  <div
    class={[props.rotated ? 'bg-yellow-orange' : '', 'w-12 h-12 rounded-full flex justify-center items-center'].join(' ')}
    style="box-shadow: 0 5px 16px 0 #080F340F"
  >
    <svg
      width="11"
      height="19"
      viewBox="0 0 11 19"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      class={props.rotated ? 'transition-transform rotate-90' : 'transition-transform rotate-0'}
    >
      <path
        d="M1.40283 17.9161L9.6221 9.65955L1.40283 1.40296"
        stroke={props.rotated ? '#FFFFFF' : '#FBA346'}
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
  </div>
);
