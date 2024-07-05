# frozen_string_literal: true

class CompanyWebhookNotifier < CompanyNotifier
  self.driver = proc do |data|
    data[:paths].each do |url|
      Webhooks::Client.new(url: url.origin).send_message(
        path: url.path,
        body: data[:body]
      )
    end
  end

  def source = Webhook::CUSTOM
end
