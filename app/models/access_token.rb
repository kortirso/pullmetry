# frozen_string_literal: true

class AccessToken < ApplicationRecord
  include Uuidable

  belongs_to :tokenable, polymorphic: true
end
