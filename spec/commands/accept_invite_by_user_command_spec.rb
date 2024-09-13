# frozen_string_literal: true

describe AcceptInviteByUserCommand do
  subject(:service_call) { described_class.new.call({ invite: invite, user: user }) }

  let!(:user) { create :user }

  context 'for company invite' do
    let!(:company) { create :company }
    let!(:invite) { create :invite, inviteable: company, access: Invite::WRITE }

    context 'without companies user' do
      it 'updates invite and creates companies user', :aggregate_failures do
        expect { service_call }.to change(Companies::User, :count).by(1)
        expect(invite.reload.code).to be_nil
      end
    end

    context 'with companies user' do
      let!(:companies_user) {
        create :companies_user, company: company, user: user, invite: invite, access: Companies::User::READ
      }

      it 'updates invite and does not create companies user', :aggregate_failures do
        expect { service_call }.not_to change(Companies::User, :count)
        expect(invite.reload.code).to be_nil
        expect(companies_user.reload.access).to eq Companies::User::READ
      end
    end
  end

  context 'for user invite' do
    let!(:another_user) { create :user }
    let!(:company) { create :company, user: another_user }
    let!(:invite) { create :invite, inviteable: another_user, access: Invite::WRITE }

    context 'without companies user' do
      it 'updates invite and creates companies user', :aggregate_failures do
        expect { service_call }.to change(Companies::User, :count).by(1)
        expect(Companies::User.last.company_id).to eq company.id
        expect(invite.reload.code).to be_nil
      end
    end

    context 'with companies user' do
      let!(:companies_user) {
        create :companies_user, company: company, user: user, invite: invite, access: Companies::User::READ
      }

      it 'updates invite and does not create companies user', :aggregate_failures do
        expect { service_call }.not_to change(Companies::User, :count)
        expect(invite.reload.code).to be_nil
        expect(companies_user.reload.access).to eq Companies::User::READ
      end
    end
  end
end
