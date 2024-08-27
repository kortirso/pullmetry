import { FormLabel, FormTextArea } from '../atoms';

export const FormDescriptionField = (props) => (
  <div className="form-field">
    {props.labelText ? (
      <FormLabel required={props.required} value={props.labelText} />
    ) : null}
    <FormTextArea
      required={props.required}
      onChange={(value) => props.onChange ? props.onChange(value) : null}
    />
  </div>
)
