# frozen_string_literal: true

describe Api::Frontend::Repositories::RepositoryInsightsController do
  describe 'GET#index' do
    context 'for logged users' do
      let!(:company) { create :company, configuration: { insight_ratio: true } }
      let!(:repository) { create :repository, company: company }
      let!(:user) { create :user }
      let!(:users_session) { create :users_session, user: user }
      let(:access_token) { Authkeeper::GenerateTokenService.new.call(users_session: users_session)[:result] }

      before do
        create :subscription, user: user
        create :repositories_insight, repository: repository, comments_count: 2
        create :repositories_insight, repository: repository, comments_count: 3, previous_date: 1.week.ago
      end

      context 'for user company' do
        before { company.update!(user: user) }

        it 'returns data', :aggregate_failures do
          get :index, params: { repository_id: repository.uuid, pullmetry_access_token: access_token }

          response_values = response.parsed_body.dig('insight', 'values')

          expect(response).to have_http_status :ok
          expect(response_values.keys).to eq Repositories::Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
          expect(response_values.dig('comments_count', 'value')).to eq 2
        end
      end
    end
  end
end
