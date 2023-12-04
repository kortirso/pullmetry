# frozen_string_literal: true

class WebhookNotifier < AbstractNotifier::Base
  self.driver = proc do |data|
    url = URI(data[:url])

    Webhooks::Client.new(url: url.origin).send_message(
      path: url.path,
      body: data[:body]
    )
  end
end
