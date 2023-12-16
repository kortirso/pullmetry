# frozen_string_literal: true

module Excludes
  class Group < ApplicationRecord
    self.table_name = :excludes_groups

    include Uuidable

    belongs_to :insightable, polymorphic: true
  end
end
