# frozen_string_literal: true

class Repository < ApplicationRecord
  include Uuidable
  include Tokenable
  include Insightable

  belongs_to :company, counter_cache: true

  has_many :pull_requests, dependent: :destroy

  def fetch_access_token
    access_token || company.access_token
  end
end
