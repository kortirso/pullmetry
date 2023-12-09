# frozen_string_literal: true

module Providerable
  extend ActiveSupport::Concern

  GITHUB = 'github'
  GITLAB = 'gitlab'
  TELEGRAM = 'telegram'

  MUST_BE_PROVIDERS = [GITHUB, GITLAB].freeze
  CAN_BE_ALWAYS_DELETED = [TELEGRAM].freeze

  included do
    enum provider: { GITHUB => 0, GITLAB => 1, TELEGRAM => 2 }
  end
end
