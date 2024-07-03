# frozen_string_literal: true

class CompanyNotifier < AbstractNotifier::Base
  private

  def report(source)
    path = webhook_path(source)
    url = URI(path)

    notification(
      **Payloads::Company.new.call(
        type: source,
        path: path,
        url: url,
        insightable: insightable,
        notification_name: notification_name
      )
    )
  end

  def insightable = params[:insightable]

  def webhook_path(source)
    webhook = insightable.all_webhooks.where(source: source).order(webhookable_type: :asc).first
    URI(webhook.url).path
  end
end
