export const FormTextArea = (props) => (
  <textarea
    rows="7"
    class={[props.classList, 'form-value'].join(' ')}
    required={props.required}
    value={props.value}
    onInput={(e) => props.onChange ? props.onChange(e.target.value) : null}
  />
)
