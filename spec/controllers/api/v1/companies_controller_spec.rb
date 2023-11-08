# frozen_string_literal: true

describe Api::V1::CompaniesController do
  describe 'POST#create' do
    context 'for logged users' do
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for invalid params' do
        let(:request) { post :create, params: { company: { title: '' }, auth_token: access_token } }

        it 'does not create company', :aggregate_failures do
          expect { request }.not_to change(Company, :count)
          expect(response).to have_http_status :ok
          expect(response.parsed_body.dig('errors', 0)).to eq "Title can't be blank"
        end
      end

      context 'for valid params' do
        let(:request) { post :create, params: { company: { title: 'Title' }, auth_token: access_token } }

        it 'creates company', :aggregate_failures do
          expect { request }.to change(user.companies, :count).by(1)
          expect(response).to have_http_status :ok
          expect(response.parsed_body['errors']).to be_nil
        end
      end
    end
  end
end
