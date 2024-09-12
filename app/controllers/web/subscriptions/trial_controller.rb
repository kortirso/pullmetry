# frozen_string_literal: true

module Web
  module Subscriptions
    class TrialController < ApplicationController
      include Deps[add_user_subscription: 'commands.add_user_subscription']

      def create
        case add_user_subscription.call(user: current_user, trial: true)
        in { errors: errors } then redirect_to profile_path, alert: errors
        else redirect_to profile_path
        end
      end
    end
  end
end
