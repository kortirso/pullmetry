# frozen_string_literal: true

class Repository < ApplicationRecord
  include Uuidable
  include Tokenable
  include Insightable
  include Providerable

  belongs_to :company, counter_cache: true

  has_many :pull_requests, dependent: :destroy
  has_many :pull_requests_comments, -> { distinct }, class_name: '::PullRequests::Comment', through: :pull_requests
  has_many :pull_requests_reviews, -> { distinct }, class_name: '::PullRequests::Review', through: :pull_requests
  has_many :repository_insights, class_name: '::Repositories::Insight', dependent: :destroy

  scope :of_user, ->(user_id) { joins(:company).where(companies: { user_id: user_id }) }
  scope :not_of_user, ->(user_id) { joins(:company).where.not(companies: { user_id: user_id }) }

  delegate :configuration, :with_work_time?, :selected_insight_fields, :premium?, to: :company

  def access_token_status
    token = fetch_access_token
    return 'empty' if token.nil?

    token.value.starts_with?(AccessToken::FORMAT_BY_PROVIDER[provider]) ? 'valid' : 'invalid'
  end
end
