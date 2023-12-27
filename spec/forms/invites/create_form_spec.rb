# frozen_string_literal: true

describe Invites::CreateForm, type: :service do
  subject(:form) { instance.call(inviteable: inviteable, params: params) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }

  context 'for user inviteable' do
    let(:inviteable) { user }

    context 'for invalid params' do
      let(:params) { { email: '' } }

      it 'does not create invite', :aggregate_failures do
        expect { form }.not_to change(Invite, :count)
        expect(form[:errors]).not_to be_blank
      end
    end

    context 'for valid params' do
      let(:params) { { email: 'email' } }

      it 'creates invite', :aggregate_failures do
        expect { form }.to change(Invite, :count).by(1)
        expect(form[:result].is_a?(Invite)).to be_truthy
        expect(form[:errors]).to be_blank
      end

      context 'for existing invite' do
        before { create :invite, email: 'email', inviteable: inviteable }

        it 'does not create invite', :aggregate_failures do
          expect { form }.not_to change(Invite, :count)
          expect(form[:errors]).not_to be_blank
        end
      end
    end
  end

  context 'for company inviteable' do
    let!(:company) { create :company }
    let(:inviteable) { company }

    context 'for invalid params' do
      let(:params) { { email: '' } }

      it 'does not create invite', :aggregate_failures do
        expect { form }.not_to change(Invite, :count)
        expect(form[:errors]).not_to be_blank
      end
    end

    context 'for valid params' do
      let(:params) { { email: 'email' } }

      it 'creates invite', :aggregate_failures do
        expect { form }.to change(Invite, :count).by(1)
        expect(form[:result].is_a?(Invite)).to be_truthy
        expect(form[:errors]).to be_blank
      end

      context 'for existing invite' do
        before { create :invite, email: 'email', inviteable: inviteable }

        it 'does not create invite', :aggregate_failures do
          expect { form }.not_to change(Invite, :count)
          expect(form[:errors]).not_to be_blank
        end
      end
    end
  end
end
