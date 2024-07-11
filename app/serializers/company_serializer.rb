# frozen_string_literal: true

class CompanySerializer < ApplicationSerializer
  ATTRIBUTES = %i[uuid title repositories_count accessable].freeze

  attributes :uuid, :title, :repositories_count, :accessable
end
