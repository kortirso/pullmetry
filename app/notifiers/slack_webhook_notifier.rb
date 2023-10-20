# frozen_string_literal: true

class SlackWebhookNotifier < AbstractNotifier::Base
  self.driver = proc do |data|
    Pullmetry::Container['api.slack.client'].send_message(
      path: data[:path],
      body: data[:body]
    )
  end
end
