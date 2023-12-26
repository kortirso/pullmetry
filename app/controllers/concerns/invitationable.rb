# frozen_string_literal: true

module Invitationable
  extend ActiveSupport::Concern

  private

  def find_invite
    return if params[:invite_code].blank? || params[:invite_email].blank?

    invite = Invite.find_by(code: params[:invite_code], email: params[:invite_email])
    return if invite.blank?

    Current.user ? accept_invite(invite.uuid) : save_invite_cookies(invite)
  end

  # rubocop: disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def accept_invite(invite_uuid=nil)
    invite_uuid ||= cookies[:pullmetry_invite_uuid]
    return unless invite_uuid

    invite = Invite.find_by(uuid: invite_uuid)
    return if invite.nil?
    # skip self invites
    return if invite.friend? && invite.inviteable_id == Current.user.id
    return if invite.coworker? && invite.inviteable.user_id == Current.user.id

    invite.update!(
      receiver: Current.user,
      email: nil,
      code: nil
    )
    cookies.delete(:pullmetry_invite_uuid)
  end
  # rubocop: enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  def save_invite_cookies(invite)
    cookies[:pullmetry_invite_uuid] = {
      value: invite.uuid,
      expires: 1.week.from_now
    }
  end
end
