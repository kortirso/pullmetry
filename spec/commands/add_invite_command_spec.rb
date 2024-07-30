# frozen_string_literal: true

describe AddInviteCommand do
  subject(:command) { instance.call(params.merge(inviteable: inviteable)) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }
  let(:mail) { double }

  before do
    allow(InvitesMailer).to receive(:create_email).and_return(mail)
    allow(mail).to receive(:deliver_later)
  end

  context 'for user inviteable' do
    let(:inviteable) { user }

    context 'for invalid params' do
      let(:params) { { email: '' } }

      it 'does not create invite', :aggregate_failures do
        expect { command }.not_to change(Invite, :count)
        expect(command[:errors]).not_to be_blank
        expect(InvitesMailer).not_to have_received(:create_email)
      end
    end

    context 'for invalid access value' do
      let(:params) { { email: 'email@gmail.com', access: 'full' } }

      it 'does not create invite', :aggregate_failures do
        expect { command }.not_to change(Invite, :count)
        expect(command[:errors]).to eq(['Access must be one of: read, write'])
        expect(InvitesMailer).not_to have_received(:create_email)
      end
    end

    context 'for valid params' do
      let(:params) { { email: 'email@gmail.com' } }

      it 'creates invite', :aggregate_failures do
        expect { command }.to change(Invite, :count).by(1)
        expect(command[:result].is_a?(Invite)).to be_truthy
        expect(command[:errors]).to be_blank
        expect(InvitesMailer).to have_received(:create_email)
      end

      context 'for existing invite' do
        before { create :invite, email: 'email@gmail.com', inviteable: inviteable }

        it 'does not create invite', :aggregate_failures do
          expect { command }.not_to change(Invite, :count)
          expect(command[:errors]).not_to be_blank
          expect(InvitesMailer).not_to have_received(:create_email)
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
        expect { command }.not_to change(Invite, :count)
        expect(command[:errors]).not_to be_blank
        expect(InvitesMailer).not_to have_received(:create_email)
      end
    end

    context 'for valid params' do
      let(:params) { { email: 'email@gmail.com' } }

      it 'creates invite', :aggregate_failures do
        expect { command }.to change(Invite, :count).by(1)
        expect(command[:result].is_a?(Invite)).to be_truthy
        expect(command[:errors]).to be_blank
        expect(InvitesMailer).to have_received(:create_email)
      end

      context 'for existing invite' do
        before { create :invite, email: 'email@gmail.com', inviteable: inviteable }

        it 'does not create invite', :aggregate_failures do
          expect { command }.not_to change(Invite, :count)
          expect(command[:errors]).not_to be_blank
          expect(InvitesMailer).not_to have_received(:create_email)
        end
      end
    end
  end
end
