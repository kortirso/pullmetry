# frozen_string_literal: true

class AddSubscriberCommand < BaseCommand
  use_contract do
    params do
      required(:email).filled(:string)
    end

    rule(:email) do
      key.failure(:invalid_format) unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
    end
  end

  private

  def do_persist(input)
    subscriber = Subscriber.create!(input)

    SubscribersMailer.create_email(id: subscriber.id).deliver_later

    { result: subscriber }
  end
end
