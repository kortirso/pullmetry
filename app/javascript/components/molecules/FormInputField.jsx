import { FormLabel, FormInput } from '../atoms';

export const FormInputField = (props) => (
  <div class="form-field">
    {props.labelText ? (
      <FormLabel required={props.required} value={props.labelText} />
    ) : null}
    <FormInput
      required={props.required}
      disabled={props.disabled}
      placeholder={props.placeholder}
      onChange={(value) => props.onChange ? props.onChange(value) : null}
    />
  </div>
)
