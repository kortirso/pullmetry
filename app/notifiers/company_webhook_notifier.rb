# frozen_string_literal: true

class CompanyWebhookNotifier < CompanyNotifier
  self.driver = proc do |data|
    Webhooks::Client.new(url: data[:path].origin).send_message(
      path: data[:path].path,
      body: data[:body]
    )
  end
end
