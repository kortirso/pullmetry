# frozen_string_literal: true

class User
  class Vacation < ApplicationRecord
    self.table_name = :vacations

    belongs_to :user
  end
end
