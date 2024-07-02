# frozen_string_literal: true

class Invite < ApplicationRecord
  include Uuidable

  READ = 'read'
  WRITE = 'write'

  has_secure_token :code, length: 24

  encrypts :email, deterministic: true

  belongs_to :inviteable, polymorphic: true
  belongs_to :receiver, class_name: '::User', foreign_key: :receiver_id, inverse_of: :receive_invites, optional: true

  has_many :companies_users, class_name: 'Companies::User', dependent: :destroy

  scope :coworker, -> { where(inviteable_type: 'Company') }
  scope :coowner, -> { where(inviteable_type: 'User') }
  scope :accepted, -> { where.not(receiver_id: nil) }
  scope :waiting, -> { where(receiver_id: nil) }

  enum access: { READ => 0, WRITE => 1 }

  def coworker?
    inviteable_type == 'Company'
  end

  def coowner?
    inviteable_type == 'User'
  end
end
