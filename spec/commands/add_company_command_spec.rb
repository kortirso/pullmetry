# frozen_string_literal: true

describe AddCompanyCommand do
  subject(:command) { instance.call(params.merge(user: user)) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }
  let!(:another_user) { create :user }

  context 'for invalid params' do
    let(:params) { { title: '' } }

    it 'does not create company and fails' do
      expect { command }.not_to change(Company, :count)
    end
  end

  context 'for valid params' do
    let(:params) { { title: 'Title' } }

    it 'creates company and succeeds' do
      expect { command }.to change(user.companies, :count).by(1)
    end

    context 'with user invites' do
      before { create :invite, inviteable: user, receiver: another_user, code: nil }

      it 'attaches receiver to company' do
        expect { command }.to(
          change(user.companies, :count).by(1)
            .and(change(Companies::User, :count).by(1))
        )
      end
    end
  end
end
