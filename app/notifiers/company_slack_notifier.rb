# frozen_string_literal: true

class CompanySlackNotifier < CompanyNotifier
  self.driver = proc do |data|
    Pullmetry::Container['api.slack.client'].send_message(
      path: data[:path],
      body: data[:body]
    )
  end
end
