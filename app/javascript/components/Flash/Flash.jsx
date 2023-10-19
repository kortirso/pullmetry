import React, { useState, useEffect } from 'react';

export const Flash = ({ values }) => {
  const [messages, setMessages] = useState(values);

  useEffect(() => {
    setTimeout(() => setMessages({}), 4000);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const flashBackground = (value) => {
    if (value === 'notice') return 'bg-green-400';

    return 'bg-red-400';
  };

  const closeMessage = (key, value) => {
    const values = messages[key].filter((element) => element !== value);
    setMessages({ ...messages, [key]: values });
  }

  const renderValues = (key, values) => {
    return values.map((value, index) => (
      <div
        className={`relative mb-2 py-4 pl-8 pr-12 rounded shadow ${flashBackground(key)}`}
        key={`${key}-${index}`}
      >
        <p>{value}</p>
        <span
          className="absolute top-1 right-1 cursor-pointer p-2"
          onClick={() => closeMessage(key, value)}
        >x</span>
      </div>
    ))
  }

  return (
    <div className="fixed top-12 right-8">
      {Object.entries(messages).map(([key, values], index) => renderValues(key, values))}
    </div>
  );
};
