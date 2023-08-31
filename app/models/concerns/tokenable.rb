# frozen_string_literal: true

module Tokenable
  extend ActiveSupport::Concern

  included do
    has_one :access_token, as: :tokenable, dependent: :destroy
  end

  def fetch_access_token
    return access_token if is_a?(Company)

    access_token || company.access_token
  end
end
