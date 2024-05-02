# frozen_string_literal: true

class CompanySerializer < ApplicationSerializer
  set_id :uuid

  attribute :uuid, if: proc { |_, params| required_field?(params, 'uuid') }, &:uuid
  attribute :title, if: proc { |_, params| required_field?(params, 'title') }, &:title
  # rubocop: disable Layout/LineLength
  attribute :repositories_count, if: proc { |_, params| required_field?(params, 'repositories_count') }, &:repositories_count
  # rubocop: enable Layout/LineLength
  attribute :accessable, if: proc { |_, params| required_field?(params, 'accessable') }, &:accessable
end
