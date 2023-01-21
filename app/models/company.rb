# frozen_string_literal: true

class Company < ApplicationRecord
  include Uuidable
  include Tokenable
  include Insightable
  include Configurable

  belongs_to :user

  has_many :repositories, dependent: :destroy
  has_many :pull_requests, -> { distinct }, through: :repositories
  has_many :entities, -> { distinct }, through: :repositories
  has_many :pull_requests_entities, -> { distinct }, class_name: '::PullRequests::Entity', through: :repositories
  has_many :pull_requests_comments, -> { distinct }, class_name: '::PullRequests::Comment', through: :repositories
  has_many :pull_requests_reviews, -> { distinct }, class_name: '::PullRequests::Review', through: :repositories

  delegate :premium?, to: :user
end
