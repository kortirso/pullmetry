# frozen_string_literal: true

describe Web::WelcomeController do
  describe 'GET#index' do
    it 'renders index template' do
      get :index

      expect(response).to render_template :index
    end

    context 'with invite code' do
      let!(:invite) { create :invite, email: 'email' }

      context 'for unlogged user' do
        context 'for unexisting invite' do
          it 'does not save invite cookies', :aggregate_failures do
            get :index, params: { invite_code: 'code', invite_email: 'email' }

            expect(response).to render_template :index
            expect(cookies[:pullmetry_invite_uuid]).to be_nil
          end
        end

        context 'for existing invite' do
          it 'saves invite cookies', :aggregate_failures do
            get :index, params: { invite_code: invite.code, invite_email: invite.email }

            expect(response).to render_template :index
            expect(cookies[:pullmetry_invite_uuid]).to eq invite.uuid
          end
        end
      end

      context 'for logged user' do
        sign_in_user

        context 'for unexisting invite' do
          it 'does not accept invite', :aggregate_failures do
            get :index, params: { invite_code: 'code', invite_email: 'email' }

            expect(response).to render_template :index
            expect(cookies[:pullmetry_invite_uuid]).to be_nil
            expect(invite.receiver).to be_nil
          end
        end

        context 'for existing invite' do
          it 'accepts invite', :aggregate_failures do
            get :index, params: { invite_code: invite.code, invite_email: invite.email }

            expect(response).to render_template :index
            expect(cookies[:pullmetry_invite_uuid]).to be_nil
            expect(invite.reload.receiver).to eq @current_user
          end
        end
      end
    end
  end

  describe 'GET#privacy' do
    it 'renders privacy template' do
      get :privacy

      expect(response).to render_template :privacy
    end
  end

  describe 'GET#metrics' do
    it 'renders metrics template' do
      get :metrics

      expect(response).to render_template :metrics
    end
  end
end
