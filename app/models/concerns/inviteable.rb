# frozen_string_literal: true

module Inviteable
  extend ActiveSupport::Concern

  included do
    has_many :invites, as: :inviteable, dependent: :destroy
  end
end
