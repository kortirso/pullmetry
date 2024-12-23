# frozen_string_literal: true

class Entity
  class Ignore < ApplicationRecord
    self.table_name = :ignores

    belongs_to :insightable, polymorphic: true
  end
end
