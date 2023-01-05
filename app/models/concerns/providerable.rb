# frozen_string_literal: true

module Providerable
  extend ActiveSupport::Concern

  GITHUB = 'github'

  included do
    enum provider: { GITHUB => 0 }
  end
end
