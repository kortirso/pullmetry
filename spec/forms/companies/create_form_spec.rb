# frozen_string_literal: true

describe Companies::CreateForm, type: :service do
  subject(:form) { described_class.call(user: user, params: params) }

  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { title: '' } }

    it 'does not create company and fails', :aggregate_failures do
      expect { form }.not_to change(Company, :count)
      expect(form.failure?).to be_truthy
    end
  end

  context 'for valid params' do
    let(:params) { { title: 'Title' } }

    it 'creates company and succeeds', :aggregate_failures do
      expect { form }.to change(user.companies, :count).by(1)
      expect(form.success?).to be_truthy
    end
  end
end
