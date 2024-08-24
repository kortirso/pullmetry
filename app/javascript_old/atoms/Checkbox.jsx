import React from 'react';

export const Checkbox = ({
  disabled = false,
  checked = false,
  labelValue,
  labelPosition = 'right',
  onEnable,
  onDisable
}) => {
  return (
    <div className="flex items-center">
      {labelValue && labelPosition === 'left' ? (
        <label className="mr-2">{labelValue}</label>
      ) : null}
      <div
        className="toggle"
        onClick={() => disabled ? null : (checked ? onDisable() : onEnable())}
      >
        <input
          checked={checked}
          disabled={disabled}
          className="toggle-checkbox"
          type="checkbox"
        />
        <label className="toggle-label" />
      </div>
      {labelValue && labelPosition === 'right' ? (
        <label className="ml-2">{labelValue}</label>
      ) : null}
    </div>
  );
};
