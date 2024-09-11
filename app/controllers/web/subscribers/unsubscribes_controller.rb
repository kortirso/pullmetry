# frozen_string_literal: true

module Web
  module Subscribers
    class UnsubscribesController < ApplicationController
      skip_before_action :authenticate
      before_action :find_subscriber
      before_action :check_unsubscribe_token

      def show
        # commento: subscribers.unsubscribe_token, subscribers.unsubscribed_at
        @subscriber.update!(unsubscribe_token: nil, unsubscribed_at: DateTime.now)
      end

      private

      def find_subscriber
        @subscriber = Subscriber.find_by(email: params[:email])
        return if @subscriber

        redirect_to root_path, alert: 'Unsubscribing can not be done'
      end

      def check_unsubscribe_token
        return if @subscriber.unsubscribe_token == params[:unsubscribe_token]

        redirect_to root_path, alert: 'Unsubscribe token is invalid'
      end
    end
  end
end
