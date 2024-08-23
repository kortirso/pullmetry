# frozen_string_literal: true

describe ChangeRepositoryCommand do
  subject(:service_call) { instance.call(repository: repository, synced_at: DateTime.now) }

  let!(:instance) { described_class.new }
  let!(:repository) { create :repository }

  it 'updates repository' do
    service_call

    expect(repository.reload.synced_at).not_to be_nil
  end
end
