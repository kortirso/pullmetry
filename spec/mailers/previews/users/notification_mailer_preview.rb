# frozen_string_literal: true

# Preview all emails at http://localhost:5000/rails/mailers/users/notification_mailer
module Users
  class NotificationMailerPreview < ActionMailer::Preview
    def repository_access_error_email
      ::Users::NotificationMailer.repository_access_error_email(id: User.last.id)
    end
  end
end
