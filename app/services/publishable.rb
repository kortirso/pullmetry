# frozen_string_literal: true

module Publishable
  private

  def publish_event(event:, data: {})
    event_store.publish(
      event.new(data: data)
    )
  end

  def event_store
    Rails.configuration.event_store
  end
end
