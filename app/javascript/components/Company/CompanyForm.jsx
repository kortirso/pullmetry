import React, { useState } from 'react';

import { Modal } from '../../atoms';
import { apiRequest, csrfToken } from '../../helpers';

export const CompanyForm = () => {
  const [pageState, setPageState] = useState({
    isOpen: false,
    title: '',
    errors: []
  });

  const onSubmit = async () => {
    const result = await apiRequest({
      url: '/api/frontend/companies.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ company: { title: pageState.title } }),
      },
    });

    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else window.location = result.redirect_path;
  };

  return (
    <>
      <p
        className="btn-primary hidden sm:block"
        onClick={() => setPageState({ ...pageState, isOpen: true })}
      >Create company</p>
      <p
        className="btn-primary sm:hidden"
        onClick={() => setPageState({ ...pageState, isOpen: true })}
      >+</p>
      <Modal
        show={pageState.isOpen}
        onClose={() => setPageState({ ...pageState, isOpen: false })}
      >
        <h1 className="mb-8">New Company</h1>
        <p className="mb-4">Company is just abstraction for collection of repositories belongs to one group with similar settings</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Title</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              className="form-value w-full"
              value={pageState.title}
              placeholder="Company's title"
              onChange={(e) => setPageState({ ...pageState, title: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onSubmit}>Save company</p>
        </section>
      </Modal>
    </>
  );
};
