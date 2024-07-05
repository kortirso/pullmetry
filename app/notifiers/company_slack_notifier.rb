# frozen_string_literal: true

class CompanySlackNotifier < CompanyNotifier
  self.driver = proc do |data|
    data[:paths].each do |path|
      Pullmetry::Container['api.slack.client'].send_message(
        path: path,
        body: data[:body]
      )
    end
  end

  def source = Webhook::SLACK
end
