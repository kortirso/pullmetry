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
  has_many :comments, class_name: 'PullRequest::Comment', dependent: :destroy
  has_many :reviews, class_name: 'PullRequest::Review', dependent: :destroy
  has_many :insights, dependent: :destroy
end
