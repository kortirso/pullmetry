# frozen_string_literal: true

describe Companies::CreateForm, type: :service do
  subject(:form) { instance.call(user: user, params: params) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { title: '' } }

    it 'does not create company and fails' do
      expect { form }.not_to change(Company, :count)
    end
  end

  context 'for valid params' do
    let(:params) { { title: 'Title' } }

    it 'creates company and succeeds' do
      expect { form }.to change(user.companies, :count).by(1)
    end
  end
end
