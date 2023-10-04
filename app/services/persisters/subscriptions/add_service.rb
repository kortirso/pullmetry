# frozen_string_literal: true

module Persisters
  module Subscriptions
    class AddService
      def call(user:, trial: false)
        user.with_lock do
          trial ? add_trial(user) : add_primary
        end
      end

      private

      def add_trial(user)
        return { errors: ["Trial subscription can't be created"] } if user.subscriptions.exists?

        time = DateTime.now
        # commento: subscriptions.start_time, subscriptions.end_time
        user.subscriptions.create!(start_time: time, end_time: time + Subscription::TRIAL_PERIOD_DAYS.days)
      end

      def add_primary; end
    end
  end
end
