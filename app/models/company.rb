# frozen_string_literal: true

class Company < ApplicationRecord
  include Uuidable
  include Tokenable
  include Insightable
  include Configurable
  include Notifyable
  include Inviteable

  belongs_to :user

  has_many :repositories, dependent: :destroy
  has_many :pull_requests, through: :repositories
  has_many :pull_requests_comments, class_name: '::PullRequests::Comment', through: :repositories
  has_many :pull_requests_reviews, class_name: '::PullRequests::Review', through: :repositories
  has_many :ignores, as: :insightable, dependent: :destroy
  has_many :webhooks, as: :webhookable, dependent: :destroy
  has_many :excludes_groups, as: :insightable, class_name: '::Excludes::Group', dependent: :destroy
  has_many :companies_users, class_name: 'Companies::User', dependent: :destroy

  delegate :premium?, to: :user

  def user_ids
    Rails.cache.fetch("company_users_ids_v1_#{id}", expires_in: 24.hours) do
      insights.actual.visible
        .joins(entity: :identity)
        .where.not(entities: { identity_id: nil })
        .pluck('identities.user_id')
    end
  end

  def all_webhooks
    Webhook.where(webhookable: self)
      .or(
        Webhook.where(
          webhookable_id: Notification.where(notifyable: self).select(:id), webhookable_type: 'Notification'
        )
      )
  end
end
