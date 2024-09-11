# frozen_string_literal: true

class Subscription < ApplicationRecord
  FREE_REPOSITORIES_AMOUNT = 5
  TRIAL_PERIOD_DAYS = 100

  REGULAR = 'regular'
  UNLIMITED = 'unlimited'

  belongs_to :user

  scope :active, -> { where('end_time > :date', date: DateTime.now.new_offset(0)) }

  enum :plan, { REGULAR => 0, UNLIMITED => 1 }

  def plan_settings
    case plan
    when REGULAR then regular_plan_settings
    when UNLIMITED then unlimited_plan_settings
    end
  end

  private

  def regular_plan_settings
    {
      repositories_limit: 15,
      month_price_euro_cents: 1000
    }
  end

  def unlimited_plan_settings
    {
      month_price_euro_cents: 2000
    }
  end
end
