export const FormTextArea = (props) => (
  <textarea
    rows="7"
    class="form-value w-full"
    required={props.required}
    value={props.value}
    onInput={(e) => props.onChange ? props.onChange(e.target.value) : null}
  />
)
