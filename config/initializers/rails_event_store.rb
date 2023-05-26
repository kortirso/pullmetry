# frozen_string_literal: true

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::Client.new
  # subscribers
  event_store.subscribe(PullRequests::Comments::CreateJob, to: [PullRequests::Comments::CreatedEvent])
  event_store.subscribe(PullRequests::Reviews::CreateJob, to: [PullRequests::Reviews::CreatedEvent])
  event_store.subscribe(PullRequests::CreateJob, to: [PullRequests::CreatedEvent])
end
