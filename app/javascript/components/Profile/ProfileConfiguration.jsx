import React, { useState } from 'react';

import { Dropdown, Modal, Select } from '../../atoms';
import { apiRequest, csrfToken, convertDate } from '../../helpers';

const INVITE_ACCESS_TARGETS = {
  read: 'Read',
  write: 'Write'
};

export const ProfileConfiguration = ({
  premiumHtml,
  settingsHtml,
  deleteHtml,
  vacations,
  acceptedInvites,
  invites,
  apiAccessTokens,
}) => {
  const [pageState, setPageState] = useState({
    vacationFormIsOpen: false,
    inviteFormIsOpen: false,
    vacations: vacations,
    acceptedInvites: acceptedInvites,
    invites: invites,
    apiAccessTokens: apiAccessTokens,
    startTime: '',
    inviteEmail: '',
    inviteAccess: 'read',
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
      ...pageState,
      vacationFormIsOpen: false,
      vacations: pageState.vacations.concat(result.result),
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

  const onInviteSave = async () => {
    const result = await apiRequest({
      url: '/api/frontend/invites.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
        body: JSON.stringify({
          invite: {
            email: pageState.inviteEmail,
            access: pageState.inviteAccess
          }
        }),
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      inviteFormIsOpen: false,
      invites: pageState.invites.concat(result.result),
      inviteEmail: '',
      errors: []
    })
  };

  const onInviteRemove = async (uuid) => {
    const result = await apiRequest({
      url: `/api/frontend/invites/${uuid}.json`,
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
      invites: pageState.invites.filter((item) => item.uuid !== uuid),
      errors: []
    })
  };

  const renderInvitesList = () => {
    if (pageState.invites.length === 0) return <p>You didn't specify any invites yet.</p>;

    return (
      <div className="zebra-list">
        <p className="mb-2 font-medium">Sent invites</p>
        {pageState.invites.map((invite) => (
          <div className="zebra-list-element" key={invite.uuid}>
            <p className="flex-1">{invite.email}</p>
            <p className="w-20">{INVITE_ACCESS_TARGETS[invite.access]}</p>
            <p
              className="btn-danger btn-xs ml-8"
              onClick={() => onInviteRemove(invite.uuid)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  const renderAcceptedInvitesList = () => {
    if (pageState.acceptedInvites.length === 0) return <></>;

    return (
      <div className="zebra-list pb-4 mb-4 border-b border-gray-200">
        <p className="mb-2 font-medium">Accepted invites</p>
        {pageState.acceptedInvites.map((invite) => (
          <div className="zebra-list-element" key={invite.uuid}>
            <p className="flex-1">{invite.email}</p>
            <p className="w-20">{INVITE_ACCESS_TARGETS[invite.access]}</p>
            <p
              className="btn-danger btn-xs ml-8"
              onClick={() => onInviteRemove(invite.uuid)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  const onCreateApiAccessToken = async () => {
    const result = await apiRequest({
      url: '/api/frontend/api_access_tokens.json',
      options: {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': csrfToken(),
        },
      },
    });
    if (result.errors) setPageState({ ...pageState, errors: result.errors })
    else setPageState({
      ...pageState,
      apiAccessTokens: pageState.apiAccessTokens.concat(result.result),
      errors: []
    })
  };

  const onApiAccessTokenRemove = async (id) => {
    const result = await apiRequest({
      url: `/api/frontend/api_access_tokens/${id}.json`,
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
      apiAccessTokens: pageState.apiAccessTokens.filter((item) => item.uuid !== id),
      errors: []
    })
  };

  const renderApiAccessTokensList = () => {
    if (pageState.apiAccessTokens.length === 0) return <p>You didn't specify any API access tokens yet.</p>;

    return (
      <div className="zebra-list">
        {pageState.apiAccessTokens.map((apiAccessToken) => (
          <div className="zebra-list-element" key={apiAccessToken.uuid}>
            <p>{apiAccessToken.value}</p>
            <p
              className="btn-danger btn-xs"
              onClick={() => onApiAccessTokenRemove(apiAccessToken.uuid)}
            >X</p>
          </div>
        ))}
      </div>
    )
  };

  return (
    <>
      <Dropdown convertChildren={false} title="Privacy">
        <div className="py-6 px-8">
          <div className="grid lg:grid-cols-2 gap-8 mb-8">
            <div>
              {renderApiAccessTokensList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => onCreateApiAccessToken()}
              >Create API access token</p>
            </div>
            <div>
              <p>In this block you can create access tokens for PullKeeper's API.</p>
            </div>
          </div>
          <div className="grid lg:grid-cols-2 gap-8 mb-8">
            <div>
              {renderAcceptedInvitesList()}
              {renderInvitesList()}
              <p
                className="btn-primary btn-small mt-4"
                onClick={() => setPageState({ ...pageState, inviteFormIsOpen: true })}
              >Invite coowner</p>
            </div>
            <div>
              <p>In this block you can specify coowners of your account.</p>
            </div>
          </div>
        </div>
      </Dropdown>
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
      <Modal
        show={pageState.inviteFormIsOpen}
        onClose={() => setPageState({ ...pageState, inviteFormIsOpen: false })}
      >
        <h1 className="mb-8">New invite</h1>
        <p className="mb-4">Invite will be send to email and after submitting such person will have access to your account.</p>
        <section className="inline-block w-full">
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Invite email</label>
              <sup className="leading-4">*</sup>
            </p>
            <input
              className="form-value w-full"
              value={pageState.inviteEmail}
              onChange={(e) => setPageState({ ...pageState, inviteEmail: e.target.value })}
            />
          </div>
          <div className="form-field">
            <p className="flex flex-row">
              <label className="form-label">Access level</label>
            </p>
            <Select
              items={INVITE_ACCESS_TARGETS}
              onSelect={(value) => setPageState({ ...pageState, inviteAccess: value })}
              selectedValue={pageState.inviteAccess}
            />
          </div>
          {pageState.errors.length > 0 ? (
            <p className="text-sm text-orange-600">{pageState.errors[0]}</p>
          ) : null}
          <p className="btn-primary mt-4" onClick={onInviteSave}>Create invite</p>
        </section>
      </Modal>
    </>
  );
};
