# frozen_string_literal: true

describe Users::OmniauthCallbacksController do
  describe 'POST#create' do
    let(:code) { nil }
    let(:request) { post :create, params: { provider: provider, code: code } }

    context 'for unexisting provider' do
      let(:provider) { 'unknown' }

      it 'redirects to root path', :aggregate_failures do
        expect { request }.not_to change(User, :count)
        expect(response).to redirect_to root_path
      end
    end

    context 'for existing provider' do
      let(:provider) { Providerable::GITHUB }

      context 'for blank code' do
        it 'redirects to root path', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to root_path
        end
      end

      context 'for present code' do
        let!(:auth_service) { double }
        let(:code) { 'code' }

        before do
          allow(Auth::Providers::Github).to receive(:call).and_return(auth_service)
        end

        context 'for invalid code' do
          before do
            allow(auth_service).to receive(:result).and_return(nil)
          end

          it 'redirects to root path', :aggregate_failures do
            expect { request }.not_to change(User, :count)
            expect(response).to redirect_to root_path
          end
        end

        context 'for valid code' do
          before do
            allow(auth_service).to receive(:result).and_return(auth_payload)
          end

          context 'for invalid payload' do
            let(:auth_payload) do
              {
                uid: '123',
                provider: 'github',
                login: 'octocat',
                email: nil
              }
            end

            it 'redirects to root path', :aggregate_failures do
              expect { request }.not_to change(User, :count)
              expect(response).to redirect_to root_path
            end
          end

          context 'for valid payload' do
            let(:auth_payload) do
              {
                uid: '123',
                provider: 'github',
                login: 'octocat',
                email: 'email@gmail.com'
              }
            end

            it 'redirects to companies path', :aggregate_failures do
              expect { request }.to change(User, :count).by(1)
              expect(response).to redirect_to companies_path
            end
          end
        end
      end
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      before { create :users_session, user: @current_user }

      it 'destroys session and redirects', :aggregate_failures do
        expect { do_request }.to change(Users::Session, :count).by(-1)
        expect(response).to redirect_to root_path
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en' }
    end
  end
end
