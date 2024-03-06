# frozen_string_literal: true

class Invite < ApplicationRecord
  include Uuidable

  has_secure_token :code, length: 24

  belongs_to :inviteable, polymorphic: true
  belongs_to :receiver, class_name: '::User', foreign_key: :receiver_id, inverse_of: :receive_invites, optional: true

  scope :coworker, -> { where(inviteable_type: 'Company') }
  scope :friend, -> { where(inviteable_type: 'User') }
  scope :accepted, -> { where.not(receiver_id: nil) }

  def coworker?
    inviteable_type == 'Company'
  end

  def friend?
    inviteable_type == 'User'
  end
end
