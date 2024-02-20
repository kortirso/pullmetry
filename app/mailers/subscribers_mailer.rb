# frozen_string_literal: true

class SubscribersMailer < ApplicationMailer
  def create_email(args={})
    @subscriber = Subscriber.find_by(id: args[:id])
    return if @subscriber.nil?

    mail(
      to: @subscriber.email,
      subject: 'PullKeeper: subscribing is confirmed'
    )
  end
end
