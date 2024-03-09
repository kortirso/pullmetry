# frozen_string_literal: true

module Companiable
  private

  def insightable = params[:insightable]

  def url(webhooks_source)
    URI(insightable.all_webhooks.where(source: webhooks_source).order(webhookable_type: :asc).first.url).path
  end
end
