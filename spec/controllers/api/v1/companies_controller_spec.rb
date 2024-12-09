# frozen_string_literal: true

describe Api::V1::CompaniesController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required valid api auth'

    context 'for logged users' do
      let!(:user) { create :user }
      let(:api_access_token) { create :api_access_token, user: user }

      before do
        create :company, user: user
        create :company
      end

      it 'returns companies data', :aggregate_failures do
        get :index, params: {
          api_access_token: api_access_token.value, only_fields: 'id,title'
        }

        expect(response).to have_http_status :ok
        expect(response.parsed_body['companies'].size).to eq 1

        attributes = response.parsed_body.dig('companies', 0)
        expect(attributes['id']).not_to be_nil
        expect(attributes['title']).not_to be_nil
        expect(attributes['repositories_count']).to be_nil
      end
    end

    def do_request(api_access_token=nil)
      get :index, params: { api_access_token: api_access_token }.compact
    end
  end
end
