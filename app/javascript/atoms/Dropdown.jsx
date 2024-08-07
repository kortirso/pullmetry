import React, { useState } from 'react';

import { Chevron } from '../assets';

export const Dropdown = ({ convertChildren = true, title, children }) => {
  const [pageState, setPageState] = useState({
    expanded: false,
  });

  const toggle = () => setPageState({ ...pageState, expanded: !pageState.expanded });

  return (
    <div className="bg-white border-b border-gray-200">
      <div
        className="cursor-pointer py-6 px-8 flex justify-between items-center"
        onClick={() => toggle()}
      >
        <h2 className="m-0 text-xl">{title}</h2>
        <Chevron rotated={pageState.expanded} />
      </div>
      {convertChildren ? (
        <div
          dangerouslySetInnerHTML={{ __html: children }}
          className={`${pageState.expanded ? 'block' : 'hidden'}`}
        >
        </div>
      ) : (
        <div className={`${pageState.expanded ? 'block' : 'hidden'}`}>
          {children}
        </div>
      )}
    </div>
  );
};
