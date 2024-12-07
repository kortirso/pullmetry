# frozen_string_literal: true

module Excludes
  class Group < ApplicationRecord
    self.table_name = :excludes_groups

    FREE_GROUPS_AMOUNT = 2

    belongs_to :insightable, polymorphic: true

    has_many :excludes_rules, class_name: 'Excludes::Rule', foreign_key: :excludes_group_id, dependent: :destroy
  end
end
