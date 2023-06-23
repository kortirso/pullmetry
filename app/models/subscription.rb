# frozen_string_literal: true

class Subscription < ApplicationRecord
  FREE_REPOSITORIES_AMOUNT = 5
  TRIAL_PERIOD_DAYS = 14

  belongs_to :user

  scope :active, -> { where('start_time < :date AND end_time > :date', date: DateTime.now.new_offset(0)) }
end
