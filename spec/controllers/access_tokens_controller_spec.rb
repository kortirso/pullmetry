# frozen_string_literal: true

describe AccessTokensController do
  let(:type) { 'unexisting' }
  let!(:company) { create :company }
  let!(:repository) { create :repository, company: company }

  describe 'GET#new' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for unexisting type' do
        it 'redirects to companies_path' do
          do_request

          expect(response).to redirect_to companies_path
        end
      end

      context 'for company type' do
        let(:type) { 'Company' }

        context 'for unexisting company' do
          it 'renders 404 page' do
            get :new, params: { tokenable_type: 'Company', tokenable_uuid: company.uuid, locale: 'en' }

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing company' do
          before { company.update!(user: @current_user) }

          it 'renders new template' do
            get :new, params: { tokenable_type: 'Company', tokenable_uuid: company.uuid, locale: 'en' }

            expect(response).to render_template :new
          end
        end
      end

      context 'for repository type' do
        let(:type) { 'Repository' }

        context 'for unexisting repository' do
          it 'renders 404 page' do
            get :new, params: { tokenable_type: 'Repository', tokenable_uuid: repository.uuid, locale: 'en' }

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing repository' do
          before { company.update!(user: @current_user) }

          it 'renders new template' do
            get :new, params: { tokenable_type: 'Repository', tokenable_uuid: repository.uuid, locale: 'en' }

            expect(response).to render_template :new
          end
        end
      end
    end

    def do_request
      get :new, params: { tokenable_type: type, tokenable_uuid: '2', locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for unexisting type' do
        it 'does not create access token' do
          expect { do_request }.not_to change(AccessToken, :count)
        end

        it 'redirects to companies_path' do
          do_request

          expect(response).to redirect_to companies_path
        end
      end

      context 'for company type' do
        let(:type) { 'Company' }

        context 'for unexisting company' do
          it 'does not create access token' do
            expect { do_request }.not_to change(AccessToken, :count)
          end

          it 'renders 404 page' do
            do_request

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing company' do
          before { company.update!(user: @current_user) }

          context 'for invalid params' do
            let(:request) {
              post :create, params: {
                tokenable_type: 'Company', tokenable_uuid: company.uuid, access_token: { value: '' }, locale: 'en'
              }
            }

            it 'does not create access token' do
              expect { request }.not_to change(AccessToken, :count)
            end

            it 'redirects to new_access_token_path' do
              request

              expect(response).to(
                redirect_to(new_access_token_path(tokenable_uuid: company.uuid, tokenable_type: 'Company'))
              )
            end
          end

          context 'for valid params' do
            let(:request) {
              post :create, params: {
                tokenable_type: 'Company', tokenable_uuid: company.uuid, access_token: { value: '1' }, locale: 'en'
              }
            }

            it 'creates access token' do
              request

              expect(AccessToken.where(tokenable: company).size).to eq 1
            end

            it 'redirects to companies_path' do
              request

              expect(response).to redirect_to companies_path
            end
          end
        end
      end

      context 'for repository type' do
        let(:type) { 'Repository' }

        context 'for unexisting repository' do
          it 'does not create access token' do
            expect { do_request }.not_to change(AccessToken, :count)
          end

          it 'renders 404 page' do
            do_request

            expect(response).to render_template 'shared/404'
          end
        end

        context 'for existing repository' do
          before { company.update!(user: @current_user) }

          context 'for invalid params' do
            let(:request) {
              post :create, params: {
                tokenable_type: 'Repository', tokenable_uuid: repository.uuid, access_token: { value: '' }, locale: 'en'
              }
            }

            it 'does not create access token' do
              expect { request }.not_to change(AccessToken, :count)
            end

            it 'redirects to new_access_token_path' do
              request

              expect(response).to(
                redirect_to(new_access_token_path(tokenable_uuid: repository.uuid, tokenable_type: 'Repository'))
              )
            end
          end

          context 'for valid params' do
            let(:request) {
              post :create, params: {
                tokenable_type: 'Repository',
                tokenable_uuid: repository.uuid,
                access_token: { value: '1' },
                locale: 'en'
              }
            }

            it 'creates access token' do
              request

              expect(AccessToken.where(tokenable: repository).size).to eq 1
            end

            it 'redirects to repositories_path' do
              request

              expect(response).to redirect_to repositories_path
            end
          end
        end
      end
    end

    def do_request
      post :create, params: { tokenable_type: type, tokenable_uuid: '2', access_token: { value: '' }, locale: 'en' }
    end
  end
end
