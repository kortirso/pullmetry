# frozen_string_literal: true

module Notifyable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :notifyable, dependent: :destroy
  end
end
