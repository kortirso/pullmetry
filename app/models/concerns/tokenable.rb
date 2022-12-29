# frozen_string_literal: true

module Tokenable
  extend ActiveSupport::Concern

  included do
    has_one :access_token, as: :tokenable, dependent: :destroy
  end
end
