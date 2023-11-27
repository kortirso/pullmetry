# frozen_string_literal: true

describe Api::Frontend::Repositories::RepositoryInsightsController do
  describe 'GET#index' do
    context 'for logged users' do
      let!(:company) { create :company }
      let!(:repository) { create :repository, company: company }
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      before { create :repositories_insight, repository: repository, comments_count: 2 }

      context 'for user company' do
        before { company.update!(user: user) }

        it 'returns data', :aggregate_failures do
          get :index, params: { repository_id: repository.uuid, auth_token: access_token }

          response_values = response.parsed_body.dig('insights', 'data', 'attributes', 'values')

          expect(response).to have_http_status :ok
          expect(response_values.keys).to eq Repositories::Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
          expect(response_values.dig('comments_count', 'value')).to eq 2
        end
      end
    end
  end
end
