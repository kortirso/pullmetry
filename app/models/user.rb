# frozen_string_literal: true

class User < ApplicationRecord
  include Kudos::Achievementable
  include Notifyable
  include Inviteable
  include Workable

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

  has_many :subscriptions, class_name: 'User::Subscription', foreign_key: :user_id, dependent: :destroy
  has_many :vacations, class_name: 'User::Vacation', foreign_key: :user_id, dependent: :destroy

  has_many :feedbacks, class_name: 'User::Feedback', dependent: :destroy

  has_many :api_access_tokens, dependent: :destroy

  has_many :companies_users, class_name: 'Companies::User', dependent: :destroy

  enum :role, { REGULAR => 0, ADMIN => 1 }

  def premium?
    Rails.cache.fetch("user/#{id}/premium", expires_in: 1.minute) { subscriptions.active.exists? }
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
