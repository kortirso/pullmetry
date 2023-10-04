# frozen_string_literal: true

describe Persisters::Users::RefreshAchievementsService, type: :service do
  subject(:service_call) { described_class.new.call }

  let!(:user) { create :user }
  let(:event_store) { Rails.configuration.event_store }

  it 'subscribes for events' do
    expect(PullRequests::Comments::CreateJob).to(
      have_subscribed_to_events(PullRequests::Comments::CreatedEvent).in(event_store)
    )
  end

  it 'publishes PullRequests::Comments::CreatedEvent' do
    service_call

    expect(event_store).to(
      have_published(an_event(PullRequests::Comments::CreatedEvent).with_data(user_uuid: user.uuid))
    )
  end
end
