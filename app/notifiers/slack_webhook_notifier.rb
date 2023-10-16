# frozen_string_literal: true

class SlackWebhookNotifier < AbstractNotifier::Base
  include Deps[slack_client: 'api.slack.client']

  self.driver = proc do |data|
    slack_client.send_message(
      path: data[:path],
      body: data[:body]
    )
  end
end
