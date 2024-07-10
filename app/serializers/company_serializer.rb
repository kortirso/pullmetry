# frozen_string_literal: true

class CompanySerializer < PankoApplicationSerializer
  ATTRIBUTES = %w[uuid title repositories_count accessable].freeze

  attributes :uuid, :title, :repositories_count, :accessable
end
