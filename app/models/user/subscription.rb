# frozen_string_literal: true

class User
  class Subscription < ApplicationRecord
    self.table_name = :subscriptions

    FREE_REPOSITORIES_AMOUNT = 5
    TRIAL_PERIOD_DAYS = 100

    belongs_to :user

    scope :active, -> { where('end_time > :date', date: DateTime.now.new_offset(0)) }
  end
end
