# frozen_string_literal: true

module Uuidable
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_uuid
  end

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
