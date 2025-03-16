# frozen_string_literal: true

class CompanySerializer < ApplicationSerializer
  ATTRIBUTES = %i[id title repositories_count accessable].freeze

  attributes :id, :title, :repositories_count, :accessable
end
