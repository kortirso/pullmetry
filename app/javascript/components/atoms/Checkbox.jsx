export const Checkbox = (props) => (
  <div className="flex items-center" onClick={() => props.onToggle()}>
    {props.labelText && props.left ? (
      <label className="mr-2 cursor-pointer">{props.labelText}</label>
    ) : null}
    <div className="toggle">
      <input
        checked={props.value}
        disabled={props.disabled}
        className="toggle-checkbox"
        type="checkbox"
      />
      <label className="toggle-label" />
    </div>
    {props.labelText && props.right ? (
      <label className="ml-2 cursor-pointer">{props.labelText}</label>
    ) : null}
  </div>
);
