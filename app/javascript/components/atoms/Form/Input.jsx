export const FormInput = (props) => (
  <input
    class="form-value w-full"
    required={props.required}
    disabled={props.disabled}
    placeholder={props.placeholder}
    onInput={(e) => props.onChange ? props.onChange(e.target.value) : null}
  />
)
