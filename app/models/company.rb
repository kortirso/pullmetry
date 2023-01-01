# frozen_string_literal: true

class Company < ApplicationRecord
  include Uuidable
  include Tokenable
  include Insightable

  belongs_to :user

  has_many :repositories, dependent: :destroy
  has_many :entities, -> { distinct }, through: :repositories
  has_many :pull_requests_comments, -> { distinct }, class_name: '::PullRequests::Comment', through: :repositories
  has_many :pull_requests_reviews, -> { distinct }, class_name: '::PullRequests::Review', through: :repositories
end
