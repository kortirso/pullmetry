# frozen_string_literal: true

class Insight < ApplicationRecord
  belongs_to :insightable, polymorphic: true
  belongs_to :entity

  scope :of_type_ids, ->(type) { where(insightable_type: type).pluck(:insightable_id).uniq }
end
