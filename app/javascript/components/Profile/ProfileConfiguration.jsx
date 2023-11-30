import React, { useState } from 'react';

import { Dropdown } from '../../components';

import { Modal } from '../../atoms';
import { apiRequest, csrfToken, convertDate } from '../../helpers';

export const ProfileConfiguration = ({
  premiumHtml,
  settingsHtml,
  identitiesHtml,
  deleteHtml,
  vacations
}) => {
  const [pageState, setPageState] = useState({
    vacationFormIsOpen: false,
    vacations: vacations.data.map((item) => item.attributes),
    startTime: '',
    endTime: '',
    errors: []
  });

  const onVacationSave = async () => {
    const result = await apiRequest({
      url: '/api/frontend/vacations.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({ vacation: { start_time: pageState.startTime, end_time: pageState.endTime } }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      vacationFormIsOpen: false,
      vacations: pageState.vacations.concat(result.result.data.attributes),
      startTime: '',
      endTime: '',
      errors: []
    })
  };

  const onVacationRemove = async (id) => {
    const result = await apiRequest({
      url: `/api/frontend/vacations/${id}.json`,
      options: {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        }
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      vacations: pageState.vacations.filter((item) => item.id !== id),
      errors: []
    })
  };

  const renderVacationsList = () => {
    if (pageState.vacations.length === 0) return <p>You didn't specify any vacations yet.</p>;

    return (
      <div className="zebra-list">
        {pageState.vacations.map((vacation) => (
          <div className="zebra-list-element" key={vacation.id}>
            <p>{convertDate(vacation.start_time)} - {convertDate(vacation.end_time)}</p>
            <p
              className="btn-danger btn-xs"
              onClick={() => onVacationRemove(vacation.id)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  return (
    <>
      <Dropdown title="Premium account">{premiumHtml}</Dropdown>
      <Dropdown convertChildren={false} title="Vacations">
        <div className="py-6 px-8">
          <div className="grid lg:grid-cols-2 gap-8">
            <div>
              {renderVacationsList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => setPageState({ ...pageState, vacationFormIsOpen: true })}
              >Add vacation</p>
            </div>
            <div>
              <p>Here you can specify your vacations, and for any of your company this time will be reduced from time spending for reviews for better calculating average times.</p>
            </div>
          </div>
        </div>
      </Dropdown>
      <Dropdown title="User settings">{settingsHtml}</Dropdown>
      <Dropdown title="Identities">{identitiesHtml}</Dropdown>
      <Dropdown title="Delete account">{deleteHtml}</Dropdown>
      <Modal
        show={pageState.vacationFormIsOpen}
        onClose={() => setPageState({ ...pageState, vacationFormIsOpen: false })}
      >
        <h1 className="mb-8">New vacation</h1>
        <p className="mb-4">Format of time can be 2023-01-01, 01-01-2023 or 01.01.2023.</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Start date</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              required
              className="form-value w-full"
              value={pageState.startTime}
              onChange={(e) => setPageState({ ...pageState, startTime: e.target.value })}
            />
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">End date</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              required
              className="form-value w-full"
              value={pageState.endTime}
              onChange={(e) => setPageState({ ...pageState, endTime: e.target.value })}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onVacationSave}>Save vacation</p>
        </section>
      </Modal>
    </>
  );
};
