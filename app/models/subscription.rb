# frozen_string_literal: true

class Subscription < ApplicationRecord
  FREE_REPOSITORIES_AMOUNT = 5
  PREMIUM_REPOSITORIES_AMOUNT = 15
  TRIAL_PERIOD_DAYS = 100

  belongs_to :user

  scope :active, -> { where('end_time > :date', date: DateTime.now.new_offset(0)) }
end
