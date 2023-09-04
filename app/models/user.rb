# frozen_string_literal: true

class User < ApplicationRecord
  include Uuidable
  include Kudos::Achievementable

  REGULAR = 'regular'
  ADMIN = 'admin'

  has_many :users_sessions, class_name: 'Users::Session', dependent: :destroy
  has_many :notifications, class_name: 'Users::Notification', dependent: :destroy

  has_many :companies, dependent: :destroy
  has_many :repositories, through: :companies

  has_many :identities, dependent: :destroy
  has_many :entities, through: :identities
  has_many :insights, through: :entities

  has_many :subscriptions, dependent: :destroy
  has_many :vacations, dependent: :destroy

  enum role: { REGULAR => 0, ADMIN => 1 }

  def premium?
    Rails.cache.fetch("user/#{id}/premium", expires_in: 1.minute) { subscriptions.active.exists? }
  end

  def with_work_time?
    work_start_time.present? && work_end_time.present?
  end

  def available_companies
    Company
      .where(user_id: id)
      .or(
        Company
        .where.not(user_id: id)
        .where(id: insights.of_type('Company').pluck(:insightable_id))
      )
  end

  def available_repositories
    Repository
      .of_user(id)
      .or(
        Repository
        .not_of_user(id)
        .where(id: insights.of_type('Repository').pluck(:insightable_id))
      )
  end
end
