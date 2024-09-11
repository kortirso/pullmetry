# frozen_string_literal: true

class WorkTime < ApplicationRecord
  belongs_to :worktimeable, polymorphic: true
end
