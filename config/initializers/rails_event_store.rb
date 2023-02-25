# frozen_string_literal: true

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::Client.new
  # subscribers
  event_store.subscribe(PullRequests::Comments::CreateJob, to: [PullRequests::Comments::CreatedEvent])
end
