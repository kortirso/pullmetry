# frozen_string_literal: true

class User < ApplicationRecord
  include Uuidable
  include Kudos::Achievementable
  include Notifyable

  REGULAR = 'regular'
  ADMIN = 'admin'

  has_many :users_sessions, class_name: 'Users::Session', dependent: :destroy

  has_many :companies, dependent: :destroy
  has_many :repositories, through: :companies

  has_many :identities, dependent: :destroy
  has_many :entities, through: :identities
  has_many :insights, through: :entities

  has_many :subscriptions, dependent: :destroy
  has_many :vacations, dependent: :destroy

  has_many :feedbacks, dependent: :destroy

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
        Company.where(id: insights.actual.visible.of_type('Company').select(:insightable_id))
      )
  end

  def available_repositories
    Repository.where(company_id: available_companies.select(:id))
  end
end
