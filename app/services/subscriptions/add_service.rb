# frozen_string_literal: true

module Subscriptions
  class AddService
    prepend ApplicationService

    def call(user:, trial: false)
      @user = user

      @user.with_lock do
        trial ? add_trial : add_primary
      end
    end

    private

    def add_trial
      return fail!("Trial subscription can't be created") if @user.subscriptions.exists?

      time = DateTime.now
      # commento: subscriptions.start_time, subscriptions.end_time
      @user.subscriptions.create!(start_time: time, end_time: time + Subscription::TRIAL_PERIOD_DAYS.days)
    end

    def add_primary; end
  end
end
