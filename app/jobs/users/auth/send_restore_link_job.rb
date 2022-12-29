# frozen_string_literal: true

module Users
  module Auth
    class SendRestoreLinkJob < ApplicationJob
      queue_as :default

      def perform(id:)
        Users::AuthMailer.password_restore_email(id: id).deliver_now
      end
    end
  end
end
