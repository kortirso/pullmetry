import React, { useState } from 'react';

import { Chevron } from '../../svg';

export const Select = ({ items, onSelect, selectedValue }) => {
  const [isOpen, setIsOpen] = useState(false);

  const selectValue = (value) => {
    onSelect(value);
    setIsOpen(false);
  };

  return (
    <div className="relative cursor-pointer">
      <div className="form-value flex justify-between items-center text-sm" onClick={() => setIsOpen(!isOpen)}>
        {selectedValue ? items[selectedValue] : ''}
        <Chevron rotated={isOpen} />
      </div>
      {isOpen ? (
        <ul className="form-dropdown">
          {Object.entries(items).map(([key, value]) => (
            <li
              className="bg-white hover:bg-gray-200 py-2 px-3"
              onClick={() => selectValue(key)}
              key={key}
            >
              {value}
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  );
};
