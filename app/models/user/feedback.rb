# frozen_string_literal: true

class User
  class Feedback < ApplicationRecord
    self.table_name = :feedbacks

    encrypts :email

    belongs_to :user
  end
end
