# frozen_string_literal: true

class Entity < ApplicationRecord
  include Uuidable
  include Providerable

  EMPTY_PAYLOAD = {
    login: 'octocat',
    html_url: 'https://github.com/octocat',
    avatar_url: 'https://avatars.githubusercontent.com/u/583231?v=4'
  }.freeze

  belongs_to :identity, optional: true

  has_many :pull_requests, dependent: :destroy
  has_many :pull_requests_comments, class_name: 'PullRequests::Comment', dependent: :destroy
  has_many :pull_requests_reviews, class_name: 'PullRequests::Review', dependent: :destroy
  has_many :insights, dependent: :destroy
end
