# frozen_string_literal: true

module Invitationable
  extend ActiveSupport::Concern

  private

  def find_invite
    return unless params[:invite_code] && params[:invite_email]

    invite = Invite.find_by(code: params[:invite_code], email: params[:invite_email])
    return if invite.blank?

    Current.user ? accept_invite(Current.user, invite.uuid) : save_invite_cookies(invite)
  end

  # rubocop: disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  def accept_invite(user, invite_uuid=nil)
    invite_uuid ||= cookies[:pullmetry_invite_uuid]
    return unless invite_uuid

    invite = Invite.find_by(uuid: invite_uuid)
    return clear_invite_cookies if invite.nil?
    # skip self invites
    return clear_invite_cookies if invite.coowner? && invite.inviteable_id == user.id
    return clear_invite_cookies if invite.coworker? && invite.inviteable.user_id == user.id

    Pullmetry::Container['services.persisters.invites.accept'].call(invite: invite, user: user)
    clear_invite_cookies
  end
  # rubocop: enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  def clear_invite_cookies
    cookies.delete(:pullmetry_invite_uuid)
  end

  def save_invite_cookies(invite)
    cookies[:pullmetry_invite_uuid] = {
      value: invite.uuid,
      expires: 1.week.from_now
    }
  end
end
