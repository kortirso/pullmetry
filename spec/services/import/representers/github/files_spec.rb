# frozen_string_literal: true

describe Import::Representers::Github::Files, type: :service do
  subject(:service_call) { described_class.new.call(data: data) }

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

  it 'returns represented object' do
    expect(service_call).to eq(
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
    )
  end
end
