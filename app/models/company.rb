# frozen_string_literal: true

class Company < ApplicationRecord
  include Uuidable
  include Tokenable
  include Insightable
  include Configurable

  belongs_to :user

  has_many :repositories, dependent: :destroy
  has_many :pull_requests, through: :repositories
  has_many :pull_requests_comments, class_name: '::PullRequests::Comment', through: :repositories
  has_many :pull_requests_reviews, class_name: '::PullRequests::Review', through: :repositories

  delegate :premium?, to: :user
end
