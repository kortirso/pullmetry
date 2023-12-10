import React from 'react';

export const Checkbox = ({
  disabled = false,
  checked = false,
  onEnable,
  onDisable
}) => {
  return (
    <div className="flex items-center">
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
    </div>
  );
};
