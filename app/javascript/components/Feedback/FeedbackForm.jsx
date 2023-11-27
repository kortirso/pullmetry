import React, { useState } from 'react';

import { Modal } from '../../atoms';
import { apiRequest, csrfToken } from '../../helpers';

export const FeedbackForm = ({ children }) => {
  const [pageState, setPageState] = useState({
    isOpen: false,
    title: '',
    description: '',
    errors: []
  });

  const onSubmit = async () => {
    const result = await apiRequest({
      url: '/api/frontend/feedback.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ feedback: { title: pageState.title, description: pageState.description } }),
      },
    });

    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({ ...pageState, isOpen: false });
  };

  return (
    <>
      <div
        dangerouslySetInnerHTML={{ __html: children }}
        onClick={() => setPageState({ ...pageState, isOpen: true })}
      ></div>
      <Modal
        show={pageState.isOpen}
        onClose={() => setPageState({ ...pageState, isOpen: false })}
      >
        <h1 className="mb-8">New feedback</h1>
        <p className="mb-4">You can directly send your question/feedback/bug report to <a href="mailto:kortirso@gmail.com" className="simple-link">email</a>, to <a href="https://t.me/kortirso" target="_blank" rel="noopener noreferrer" className="simple-link">Telegram</a> or just leave here.</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <label className="form-label">Title</label>
            <input
              className="form-value w-full"
              value={pageState.title}
              onChange={(e) => setPageState({ ...pageState, title: e.target.value })}
            />
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Description</label>
              <sup className="leading-4">*</sup>
            </p>
            <textarea
              rows="7"
              className="form-value w-full"
              value={pageState.description}
              onChange={(e) => setPageState({ ...pageState, description: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onSubmit}>Send feedback</p>
        </section>
      </Modal>
    </>
  );
};
