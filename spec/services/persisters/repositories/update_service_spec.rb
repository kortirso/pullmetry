# frozen_string_literal: true

describe Persisters::Repositories::UpdateService, type: :service do
  subject(:service_call) { described_class.new.call(repository: repository, params: params) }

  let!(:repository) { create :repository }
  let(:params) { { synced_at: DateTime.now } }

  it 'updates repository' do
    service_call

    expect(repository.reload.synced_at).not_to be_nil
  end
end
