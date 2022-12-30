# frozen_string_literal: true

class Entity < ApplicationRecord
  include Uuidable

  GITHUB = 'github'

  enum source: { GITHUB => 0 }
end
