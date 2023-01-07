# frozen_string_literal: true

class User < ApplicationRecord
  include Uuidable

  has_one :users_session, class_name: 'Users::Session', dependent: :destroy

  has_many :companies, dependent: :destroy
  has_many :repositories, through: :companies

  has_many :identities, dependent: :destroy
  has_many :entities, through: :identities
  has_many :insights, -> { distinct }, through: :entities

  has_many :subscriptions, dependent: :destroy

  # rubocop: disable Rails/WhereExists
  def premium?
    subscriptions.where('start_time < :date AND end_time > :date', date: DateTime.now.new_offset(0)).exists?
  end
  # rubocop: enable Rails/WhereExists
end
