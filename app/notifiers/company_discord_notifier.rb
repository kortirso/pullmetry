# frozen_string_literal: true

class CompanyDiscordNotifier < CompanyNotifier
  self.driver = proc do |data|
    data[:paths].each do |path|
      Pullmetry::Container['api.discord.client'].send_message(
        path: path,
        body: data[:body]
      )
    end
  end

  def source = Webhook::DISCORD
end
