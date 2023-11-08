# frozen_string_literal: true

class AccessToken < ApplicationRecord
  include Uuidable

  FORMAT_BY_PROVIDER = {
    Providerable::GITHUB => 'github_pat_',
    Providerable::GITLAB => 'glpat-'
  }.freeze

  belongs_to :tokenable, polymorphic: true
end
