# frozen_string_literal: true

describe Frontend::Repositories::RepositoryInsightsController do
  describe 'GET#index' do
    context 'for logged users' do
      let!(:company) { create :company, config: { insight_ratio: true } }
      let!(:repository) { create :repository, company: company }
      let!(:user) { create :user }
      let!(:user_session) { create :user_session, user: user }
      let(:access_token) { Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result] }

      before do
        create :user_subscription, user: user
        create :repositories_insight, repository: repository, comments_count: 2
        create :repositories_insight, repository: repository, comments_count: 3, previous_date: 1.week.ago
      end

      context 'for user company' do
        before { company.update!(user: user) }

        it 'returns data', :aggregate_failures do
          get :index, params: { repository_id: repository.id, pullmetry_access_token: access_token }

          response_values = response.parsed_body.dig('insight', 'values')

          expect(response).to have_http_status :ok
          expect(response_values.keys).to eq Repositories::Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
          expect(response_values.dig('comments_count', 'value')).to eq 2
        end
      end
    end
  end
end
