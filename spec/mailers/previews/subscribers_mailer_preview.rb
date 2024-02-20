# frozen_string_literal: true

# Preview all emails at http://localhost:5000/rails/mailers/subscribers_mailer
class SubscribersMailerPreview < ActionMailer::Preview
  def create_email
    SubscribersMailer.create_email(id: Subscriber.last.id)
  end
end
