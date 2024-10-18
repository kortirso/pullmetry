# frozen_string_literal: true

class AddUserSubscriptionCommand < BaseCommand
  use_contract do
    config.messages.namespace = :user

    params do
      required(:user).filled(type?: User)
      required(:trial).filled(:bool)
      optional(:days_period).filled(:integer)
      optional(:invoice_id).filled(:string)
    end
  end

  private

  def do_persist(input)
    result =
      input[:user].with_lock do
        input[:trial] ? add_trial(input) : add_primary(input)
      end
    return { errors: [result] } if result.is_a?(String)

    { result: input[:user] }
  end

  def add_trial(input)
    return "Trial subscription can't be created" if input[:user].subscriptions.exists?

    create_subscription(
      input[:user],
      DateTime.now,
      User::Subscription::TRIAL_PERIOD_DAYS
    )
  end

  def add_primary(input)
    max_end_time = input[:user].subscriptions.active.maximum(:end_time)
    create_subscription(
      input[:user],
      max_end_time.presence || DateTime.now,
      input[:days_period],
      input[:invoice_id]
    )
  end

  def create_subscription(user, time, days_period, invoice_id=nil)
    # commento: subscriptions.start_time, subscriptions.end_time, subscriptions.external_invoice_id
    user.subscriptions.create!(
      start_time: time,
      end_time: time + days_period.days,
      external_invoice_id: invoice_id
    )
  end
end
