import React from 'react';
import ReactDOM from 'react-dom';

export const Modal = ({ show, onClose, children }) => {
  const modalContent = show ? (
    <div className="fixed top-0 left-0 w-full h-full z-50 bg-stone-700/75 flex items-center justify-center">
      <div className="modal">
        <div className="modal-content">
          <div className="btn-primary btn-small absolute top-4 right-4 px-3 rounded z-10" onClick={onClose}>
            X
          </div>
          {children}
        </div>
      </div>
    </div>
  ) : null;

  if (modalContent) {
    return ReactDOM.createPortal(modalContent, window.document.getElementById('modal-root'));
  } else {
    return <></>;
  }
};
