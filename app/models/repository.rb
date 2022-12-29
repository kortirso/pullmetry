# frozen_string_literal: true

class Repository < ApplicationRecord
  include Uuidable

  belongs_to :company

  has_many :pull_requests, dependent: :destroy
end
