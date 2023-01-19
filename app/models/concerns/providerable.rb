# frozen_string_literal: true

module Providerable
  extend ActiveSupport::Concern

  GITHUB = 'github'
  GITLAB = 'gitlab'

  included do
    enum provider: { GITHUB => 0, GITLAB => 1 }
  end
end
