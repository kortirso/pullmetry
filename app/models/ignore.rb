# frozen_string_literal: true

class Ignore < ApplicationRecord
  include Uuidable

  belongs_to :insightable, polymorphic: true
end
