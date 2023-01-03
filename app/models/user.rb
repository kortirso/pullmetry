# frozen_string_literal: true

class User < ApplicationRecord
  include Uuidable

  has_one :users_session, class_name: 'Users::Session', dependent: :destroy

  has_many :companies, dependent: :destroy
  has_many :repositories, through: :companies

  has_many :identities, dependent: :destroy
  has_many :entities, through: :identities
  has_many :insights, -> { distinct }, through: :entities

  scope :not_confirmed, -> { where(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end
end
