export const FormLabel = (props) => (
  <label className="form-label">
    {props.value}
    {props.required ? <sup className="leading-4">*</sup> : null}
  </label>
)
