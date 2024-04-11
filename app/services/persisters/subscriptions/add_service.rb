# frozen_string_literal: true

module Persisters
  module Subscriptions
    class AddService
      def call(
        user:,
        trial: false,
        days_period: Subscription::TRIAL_PERIOD_DAYS,
        plan: Subscription::REGULAR,
        invoice_id: nil
      )
        user.with_lock do
          trial ? add_trial(user, days_period) : add_primary(user, days_period, plan, invoice_id)
        end
      end

      private

      def add_trial(user, days_period)
        return { errors: ["Trial subscription can't be created"] } if user.subscriptions.exists?

        create_subscription(user, DateTime.now, days_period, Subscription::REGULAR)
      end

      def add_primary(user, days_period, plan, invoice_id)
        max_end_time = user.subscriptions.active.maximum(:end_time)
        create_subscription(user, max_end_time.presence || DateTime.now, days_period, plan, invoice_id)
      end

      def create_subscription(user, time, days_period, plan, invoice_id=nil)
        # commento: subscriptions.start_time, subscriptions.end_time, subscriptions.external_invoice_id
        # commento: subscriptions.plan
        user.subscriptions.create!(
          start_time: time,
          end_time: time + days_period.days,
          external_invoice_id: invoice_id,
          plan: plan
        )
      end
    end
  end
end
