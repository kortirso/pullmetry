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

    context 'for github' do
      let(:provider) { Providerable::GITHUB }

      context 'for blank code' do
        it 'redirects to root path', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to root_path
        end
      end

      context 'for present code' do
        let(:code) { 'code' }

        before do
          allow(Pullmetry::Container.resolve('services.auth.providers.github')).to(
            receive(:call).and_return(github_auth_result)
          )
        end

        context 'for invalid code' do
          let(:github_auth_result) { { result: nil } }

          it 'redirects to root path', :aggregate_failures do
            expect { request }.not_to change(User, :count)
            expect(response).to redirect_to root_path
          end
        end

        context 'for valid code' do
          let(:github_auth_result) { { result: auth_payload } }

          context 'for not logged user' do
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

              context 'with invite uuid in session' do
                let!(:invite) { create :invite }

                before do
                  cookies[:pullmetry_invite_uuid] = {
                    value: invite.uuid,
                    expires: 1.week.from_now
                  }
                end

                it 'redirects to companies path', :aggregate_failures do
                  expect { request }.to change(User, :count).by(1)
                  expect(invite.reload.receiver).to eq User.last
                  expect(response).to redirect_to companies_path
                end
              end
            end
          end

          context 'for logged user' do
            sign_in_user

            context 'for payload without email' do
              let(:auth_payload) do
                {
                  uid: '123',
                  provider: 'github',
                  login: 'octocat',
                  email: nil
                }
              end

              it 'redirects to profile path', :aggregate_failures do
                expect { request }.to change(Identity, :count).by(1)
                expect(response).to redirect_to profile_path
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

              it 'redirects to profile path', :aggregate_failures do
                expect { request }.to change(Identity, :count).by(1)
                expect(response).to redirect_to profile_path
              end
            end
          end
        end
      end
    end

    context 'for gitlab' do
      let(:provider) { Providerable::GITLAB }

      context 'for blank code' do
        it 'redirects to root path', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to root_path
        end
      end

      context 'for present code' do
        let(:code) { 'code' }

        before do
          allow(Pullmetry::Container.resolve('services.auth.providers.gitlab')).to(
            receive(:call).and_return(github_auth_result)
          )
        end

        context 'for invalid code' do
          let(:github_auth_result) { { result: nil } }

          it 'redirects to root path', :aggregate_failures do
            expect { request }.not_to change(User, :count)
            expect(response).to redirect_to root_path
          end
        end

        context 'for valid code' do
          let(:github_auth_result) { { result: auth_payload } }

          context 'for not logged user' do
            context 'for invalid payload' do
              let(:auth_payload) do
                {
                  uid: '123',
                  provider: 'gitlab',
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
                  provider: 'gitlab',
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

          context 'for logged user' do
            sign_in_user

            context 'for payload without email' do
              let(:auth_payload) do
                {
                  uid: '123',
                  provider: 'gitlab',
                  login: 'octocat',
                  email: nil
                }
              end

              it 'redirects to profile path', :aggregate_failures do
                expect { request }.to change(Identity, :count).by(1)
                expect(response).to redirect_to profile_path
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

              it 'redirects to profile path', :aggregate_failures do
                expect { request }.to change(Identity, :count).by(1)
                expect(response).to redirect_to profile_path
              end
            end
          end
        end
      end
    end

    context 'for telegram' do
      let(:request) { post :create, params: { provider: provider, id: id } }
      let(:id) { nil }
      let(:provider) { Identity::TELEGRAM }

      context 'for blank id' do
        it 'redirects to login path', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to root_path
        end
      end

      context 'for present id' do
        let(:id) { 'id' }

        before do
          allow(Pullmetry::Container.resolve('services.auth.providers.telegram')).to(
            receive(:call).and_return(telegram_auth_result)
          )
        end

        context 'for invalid id' do
          let(:telegram_auth_result) { { result: nil } }

          it 'redirects to login path', :aggregate_failures do
            expect { request }.not_to change(User, :count)
            expect(response).to redirect_to root_path
          end
        end

        context 'for valid id' do
          let(:telegram_auth_result) { { result: auth_payload } }

          context 'for not logged user' do
            context 'for valid payload' do
              let(:auth_payload) do
                {
                  uid: '123',
                  provider: 'telegram',
                  login: 'octocat'
                }
              end

              it 'redirects to root path', :aggregate_failures do
                expect { request }.not_to change(User, :count)
                expect(response).to redirect_to root_path
              end
            end
          end

          context 'for logged user' do
            sign_in_user

            context 'for valid payload' do
              let(:auth_payload) do
                {
                  uid: '123',
                  provider: 'telegram',
                  login: 'octocat'
                }
              end

              it 'redirects to profile path', :aggregate_failures do
                expect { request }.to change(Identity, :count).by(1)
                expect(response).to redirect_to profile_path
              end
            end
          end
        end
      end
    end

    context 'for google' do
      let(:provider) { Providerable::GOOGLE }

      context 'for blank code' do
        it 'redirects to root_path', :aggregate_failures do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to root_path
        end
      end

      context 'for present code' do
        let(:code) { 'code' }

        before do
          allow(Pullmetry::Container.resolve('services.auth.providers.google')).to(
            receive(:call).and_return(google_auth_result)
          )
        end

        context 'for invalid id' do
          let(:google_auth_result) { { result: nil } }

          it 'redirects to root_path', :aggregate_failures do
            expect { request }.not_to change(User, :count)
            expect(response).to redirect_to root_path
          end
        end

        context 'for valid id' do
          let(:google_auth_result) { { result: auth_payload } }

          context 'for not logged user' do
            context 'for valid payload' do
              let(:auth_payload) do
                {
                  uid: '1',
                  provider: 'google',
                  email: 'email'
                }
              end

              it 'redirects to companies_path', :aggregate_failures do
                expect { request }.to(
                  change(User, :count).by(1)
                    .and(change(Identity, :count).by(1))
                )
                expect(response).to redirect_to companies_path
              end
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
