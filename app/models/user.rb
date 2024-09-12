# frozen_string_literal: true

class User < ApplicationRecord
  include Uuidable
  include Kudos::Achievementable
  include Notifyable
  include Inviteable

  REGULAR = 'regular'
  ADMIN = 'admin'

  encrypts :email, deterministic: true

  # TODO: remember to modify RemoveUserCommand after adding new has_many
  has_many :sessions, class_name: 'User::Session', dependent: :destroy
  has_many :receive_invites, class_name: 'Invite', foreign_key: :receiver_id, dependent: :nullify

  has_many :companies, dependent: :destroy
  has_many :repositories, through: :companies

  has_many :identities, dependent: :destroy
  has_many :entities, through: :identities
  has_many :insights, through: :entities

  has_many :subscriptions, dependent: :destroy
  has_many :vacations, class_name: 'User::Vacation', foreign_key: :user_id, dependent: :destroy

  has_many :feedbacks, dependent: :destroy

  has_many :api_access_tokens, dependent: :destroy

  has_many :companies_users, class_name: 'Companies::User', dependent: :destroy

  has_one :work_time, as: :worktimeable, dependent: :destroy

  enum :role, { REGULAR => 0, ADMIN => 1 }

  def plan_settings
    Rails.cache.fetch("user/#{id}/plan_limits", expires_in: 1.minute) do
      subscriptions.active.order(id: :asc).first&.plan_settings
    end
  end

  def premium?
    Rails.cache.fetch("user/#{id}/premium", expires_in: 1.minute) { subscriptions.active.exists? }
  end

  def with_work_time?
    work_time.present?
  end

  def available_companies
    Company.where(user_id: id)
      .or(Company.where(id: insights.actual.visible.of_type('Company').select(:insightable_id)))
      .or(Company.where(id: companies_users.select(:company_id)))
  end

  def available_write_companies
    Company.where(user_id: id)
      .or(Company.where(id: companies_users.write.select(:company_id)))
  end

  def available_repositories
    Repository.where(company_id: available_companies.select(:id))
  end
end
