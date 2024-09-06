# frozen_string_literal: true

describe 'Companies' do
  describe 'GET#index' do
    it_behaves_like 'required request auth'

    context 'for logged users' do
      sign_in_user

      context 'without companies' do
        it 'renders index page', :aggregate_failures do
          do_request

          expect(response).to render_template :index
          expect(response.body).to include('Companies')
        end
      end

      context 'with companies' do
        let!(:company1) { create :company, title: 'Another company' }
        let!(:company2) { create :company, user: @current_user, title: 'User company' }

        it 'renders index page', :aggregate_failures do
          do_request

          expect(response).to render_template :index
          expect(response.body).to include('Companies')
          expect(response.body).not_to include(company1.title)
          expect(response.body).to include(company2.title)
        end
      end
    end

    def do_request
      get '/companies'
    end
  end
end
