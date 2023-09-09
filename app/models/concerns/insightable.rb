# frozen_string_literal: true

module Insightable
  extend ActiveSupport::Concern

  included do
    has_many :insights, as: :insightable, dependent: :destroy
  end
end
