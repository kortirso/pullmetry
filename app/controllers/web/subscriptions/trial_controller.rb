# frozen_string_literal: true

module Web
  module Subscriptions
    class TrialController < ApplicationController
      include Deps[add_service: 'services.persisters.subscriptions.add']

      def create
        case add_service.call(user: current_user, trial: true)
        in { errors: errors } then redirect_to profile_path, alert: errors
        else redirect_to profile_path
        end
      end
    end
  end
end
