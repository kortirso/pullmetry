# frozen_string_literal: true

describe Import::Savers::Files, type: :service do
  subject(:service_call) { described_class.call(pull_request: pull_request, data: data) }

  let!(:pull_request) { create :pull_request }
  let(:data) {
    [
      {
        changed_loc: 1
      },
      {
        changed_loc: 2
      },
      {
        changed_loc: 3
      }
    ]
  }

  it 'updates pull request and succeeds', :aggregate_failures do
    expect { service_call }.to change(pull_request, :changed_loc).from(0).to(6)
    expect(service_call.success?).to be_truthy
  end
end
