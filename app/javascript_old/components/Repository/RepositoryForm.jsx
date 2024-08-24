import React, { useState } from 'react';

import { Modal } from '../../atoms';
import { apiRequest, csrfToken } from '../../helpers';

export const RepositoryForm = ({ company_uuid, companies, providers }) => {
  const [pageState, setPageState] = useState({
    isOpen: false,
    companyUuid: company_uuid || companies[0].uuid,
    title: '',
    link: '',
    provider: providers[0][1],
    externalId: '',
    errors: []
  });

  const onSubmit = async () => {
    const result = await apiRequest({
      url: '/api/frontend/repositories.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({
          repository: {
            company_uuid: pageState.companyUuid,
            title: pageState.title,
            link: pageState.link,
            provider: pageState.provider,
            external_id: pageState.externalId
          }
        }),
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
      >Create repository</p>
      <p
        className="btn-primary sm:hidden"
        onClick={() => setPageState({ ...pageState, isOpen: true })}
      >+</p>
      <Modal
        show={pageState.isOpen}
        onClose={() => setPageState({ ...pageState, isOpen: false })}
      >
        <h1 className="mb-8">New Repository</h1>
        <p className="mb-4">Repository is just abstraction of your real repository. Link must be real, title - anything you want.</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Company</label>
              <sup className="leading-4">*</sup>
            </p>
            <select
              className="form-value w-full"
              value={pageState.companyUuid}
              onChange={(e) => setPageState({ ...pageState, companyUuid: e.target.value })}
            >
              {companies.map(option => (
                <option key={option.uuid} value={option.uuid}>
                  {option.title}
                </option>
              ))}
            </select>
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Title</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              className="form-value w-full"
              value={pageState.title}
              placeholder="Repository's title"
              onChange={(e) => setPageState({ ...pageState, title: e.target.value })}
            />
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Link</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              className="form-value w-full"
              value={pageState.link}
              placeholder="https://github.com/company_name/repo_name"
              onChange={(e) => setPageState({ ...pageState, link: e.target.value })}
            />
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Provider</label>
              <sup className="leading-4">*</sup>
            </p>
            <select
              className="form-value w-full"
              value={pageState.provider}
              onChange={(e) => setPageState({ ...pageState, provider: e.target.value })}
            >
              {providers.map(option => (
                <option key={option[1]} value={option[1]}>
                  {option[0]}
                </option>
              ))}
            </select>
          </div>
          <div className="form-field">
            <label className="form-label">External id</label>
            <input
              className="form-value w-full"
              value={pageState.externalId}
              onChange={(e) => setPageState({ ...pageState, externalId: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onSubmit}>Save repository</p>
        </section>
      </Modal>
    </>
  );
};
