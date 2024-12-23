# frozen_string_literal: true

class User
  class Session < ApplicationRecord
    self.table_name = :users_sessions

    belongs_to :user
  end
end
