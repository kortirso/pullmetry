# frozen_string_literal: true

describe Import::Files::Github, type: :service do
  subject(:service_call) { described_class.new.call(pull_request: pull_request) }

  let!(:pull_request) { create :pull_request }
  let(:data) {
    [
      {
        'status' => 'added',
        'changes' => 1
      },
      {
        'status' => 'modified',
        'changes' => 2
      },
      {
        'status' => 'renamed',
        'changes' => 3
      }
    ]
  }

  before do
    allow(Pullmetry::Container.resolve('services.import.fetchers.github.files')).to(
      receive(:call).and_return({ result: data })
    )
  end

  it 'updates pull request' do
    expect { service_call }.to change(pull_request, :changed_loc).from(0).to(6)
  end
end
