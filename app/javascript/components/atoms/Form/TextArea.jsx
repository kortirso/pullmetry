export const FormTextArea = (props) => (
  <textarea
    rows="7"
    className="form-value w-full"
    required={props.required}
    onInput={(e) => props.onChange ? props.onChange(e.target.value) : null}
  />
)
