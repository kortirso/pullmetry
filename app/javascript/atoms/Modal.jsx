import React from 'react';
import ReactDOM from 'react-dom';

export const Modal = ({ show, onClose, children }) => {
  const modalContent = show ? (
    <div className="fixed top-0 left-0 right-0 bottom-0 z-50 bg-stone-700/75 flex items-center justify-center">
      <div className="absolute p-8 bg-white rounded w-4/5 md:w-3/5 lg:w-2/5">
        <div className="btn-primary btn-small absolute -top-3 -right-3 px-3 rounded" onClick={onClose}>
          X
        </div>
        {children}
      </div>
    </div>
  ) : null;

  if (modalContent) {
    return ReactDOM.createPortal(modalContent, window.document.getElementById('modal-root'));
  } else {
    return <></>;
  }
};
