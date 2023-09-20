# frozen_string_literal: true

describe AccessTokensController do
  let!(:company) { create :company }
  let!(:repository) { create :repository, company: company }

  describe 'GET#new' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for company type' do
        context 'for unexisting company' do
          it 'renders 404 page' do
            do_request

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing company' do
          before { company.update!(user: @current_user) }

          it 'renders new template' do
            get :new, params: { company_id: company.uuid, locale: 'en' }

            expect(response).to render_template :new
          end
        end
      end

      context 'for repository type' do
        context 'for unexisting repository' do
          it 'renders 404 page' do
            get :new, params: { repository_id: 'unexisting', locale: 'en' }

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing repository' do
          before { company.update!(user: @current_user) }

          it 'renders new template' do
            get :new, params: { repository_id: repository.uuid, locale: 'en' }

            expect(response).to render_template :new
          end
        end
      end
    end

    def do_request
      get :new, params: { company_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for company type' do
        context 'for unexisting company' do
          it 'does not create access token and redirects', :aggregate_failures do
            expect { do_request }.not_to change(AccessToken, :count)
            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing company' do
          before { company.update!(user: @current_user) }

          context 'for invalid params' do
            let(:request) {
              post :create, params: { company_id: company.uuid, access_token: { value: '' }, locale: 'en' }
            }

            it 'does not create access token and redirects', :aggregate_failures do
              expect { request }.not_to change(AccessToken, :count)
              expect(response).to redirect_to(new_company_access_token_path(company.uuid))
            end
          end

          context 'for valid params' do
            let(:request) {
              post :create, params: { company_id: company.uuid, access_token: { value: '1' }, locale: 'en' }
            }

            it 'creates access token and redirects', :aggregate_failures do
              request

              expect(AccessToken.where(tokenable: company).size).to eq 1
              expect(response).to redirect_to companies_path
            end
          end
        end
      end

      context 'for repository type' do
        let(:request) {
          post :create, params: { repository_id: repository_id, access_token: { value: '' }, locale: 'en' }
        }

        context 'for unexisting repository' do
          let(:repository_id) { 'unexisting' }

          it 'does not create access token', :aggregate_failures do
            expect { do_request }.not_to change(AccessToken, :count)
            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing repository' do
          let(:repository_id) { repository.uuid }

          before { company.update!(user: @current_user) }

          context 'for invalid params' do
            it 'does not create access token and redirects', :aggregate_failures do
              expect { request }.not_to change(AccessToken, :count)
              expect(response).to redirect_to(new_repository_access_token_path(repository.uuid))
            end
          end

          context 'for valid params' do
            let(:request) {
              post :create, params: { repository_id: repository_id, access_token: { value: '1' }, locale: 'en' }
            }

            context 'without other tokens' do
              it 'creates access token and redirects', :aggregate_failures do
                request

                expect(AccessToken.where(tokenable: repository).size).to eq 1
                expect(response).to redirect_to repositories_path
              end
            end

            context 'with another token' do
              before { create :access_token, tokenable: repository }

              it 'creates access token and redirects', :aggregate_failures do
                request

                expect(AccessToken.where(tokenable: repository).size).to eq 1
                expect(response).to redirect_to repositories_path
              end
            end
          end
        end
      end
    end

    def do_request
      post :create, params: { company_id: 'unexisting', access_token: { value: '' }, locale: 'en' }
    end
  end
end
