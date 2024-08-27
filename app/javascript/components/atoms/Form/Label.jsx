export const FormLabel = (props) => (
  <label class="form-label">
    {props.value}
    {props.required ? <sup class="leading-4">*</sup> : null}
  </label>
)
