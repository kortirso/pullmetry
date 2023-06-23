# frozen_string_literal: true

module Subscriptions
  class TrialController < ApplicationController
    def create
      service_call = Subscriptions::AddService.call(user: current_user, trial: true)
      if service_call.success?
        redirect_to profile_path, notice: 'Subscription is added'
      else
        redirect_to profile_path, alert: service_call.errors
      end
    end
  end
end
