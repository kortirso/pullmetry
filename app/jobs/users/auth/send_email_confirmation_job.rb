# frozen_string_literal: true

module Users
  module Auth
    class SendEmailConfirmationJob < ApplicationJob
      queue_as :default

      def perform(id:)
        Users::AuthMailer.confirmation_email(id: id).deliver_now
      end
    end
  end
end
