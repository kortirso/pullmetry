# frozen_string_literal: true

describe Web::ProfilesController do
  describe 'GET#show' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      it 'renders show template' do
        create :identity, user: @current_user

        do_request

        expect(response).to render_template :show
      end
    end

    def do_request
      get :show, params: { locale: 'en' }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      let!(:company) { create :company, user: @current_user }
      let!(:repository) { create :repository, company: company }

      before do
        create :company
        create :access_token, tokenable: repository
      end

      it 'does not fully destroy user' do
        do_request

        expect(User.find_by(id: @current_user)).to eq @current_user
      end

      it 'destroys user companies and redirects', :aggregate_failures do
        expect { do_request }.to change(@current_user.companies, :count).by(-1)
        expect(response).to redirect_to root_path
      end

      it 'destroys user repositories and redirects', :aggregate_failures do
        expect { do_request }.to change(@current_user.repositories, :count).by(-1)
        expect(response).to redirect_to root_path
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en' }
    end
  end
end
