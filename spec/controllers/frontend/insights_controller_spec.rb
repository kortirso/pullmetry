# frozen_string_literal: true

describe Frontend::InsightsController do
  describe 'GET#index' do
    context 'for logged users' do
      let!(:company) { create :company, config: { insight_ratio: true } }
      let!(:user) { create :user }
      let!(:user_session) { create :user_session, user: user }
      let(:access_token) { Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result] }

      before { create :user_subscription, user: user }

      context 'for companies' do
        before do
          insight = create :insight, insightable: company, comments_count: 1
          create :insight, insightable: company, comments_count: 2, previous_date: 1.week.ago, entity: insight.entity
        end

        context 'for user company' do
          before { company.update!(user: user) }

          it 'returns data', :aggregate_failures do
            get :index, params: { company_id: company.uuid, pullmetry_access_token: access_token, format: :json }

            response_values = response.parsed_body.dig('insights', 0, 'values')

            expect(response).to have_http_status :ok
            expect(response_values.keys).to match_array Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
            expect(response_values.dig('comments_count', 'value')).to eq 1
          end

          context 'for selected insight fields' do
            before do
              company.config.insight_fields = {
                comments_count: true,
                reviews_count: true,
                bad_reviews_count: false,
                open_pull_requests_count: false,
                time_since_last_open_pull_seconds: false,
                average_review_seconds: false,
                average_reviewed_loc: false,
                average_changed_loc: false
              }
              company.save!
            end

            it 'returns data', :aggregate_failures do
              get :index, params: { company_id: company.uuid, pullmetry_access_token: access_token, format: :json }

              response_values = response.parsed_body.dig('insights', 0, 'values')

              expect(response).to have_http_status :ok
              expect(response_values.keys).to contain_exactly('comments_count', 'reviews_count')
              expect(response_values.dig('comments_count', 'value')).to eq 1
            end
          end

          context 'for change ratio' do
            before do
              company.config.insight_ratio_type = 'change'
              company.save!
            end

            it 'returns data', :aggregate_failures do
              get :index, params: { company_id: company.uuid, pullmetry_access_token: access_token, format: :json }

              response_values = response.parsed_body.dig('insights', 0, 'values')

              expect(response).to have_http_status :ok
              expect(response_values.keys).to match_array Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
              expect(response_values.dig('comments_count', 'value')).to eq 1
            end
          end

          context 'for pdf request' do
            it 'returns data' do
              get :index, params: { company_id: company.uuid, pullmetry_access_token: access_token, format: :pdf }

              expect(response).to have_http_status :ok
            end
          end
        end
      end

      context 'for repositories' do
        let!(:repository) { create :repository, company: company }

        before { create :insight, insightable: repository, comments_count: 2 }

        context 'for user company' do
          before { company.update!(user: user) }

          it 'returns data', :aggregate_failures do
            get :index, params: { repository_id: repository.uuid, pullmetry_access_token: access_token, format: :json }

            response_values = response.parsed_body.dig('insights', 0, 'values')

            expect(response).to have_http_status :ok
            expect(response_values.keys).to match_array Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
            expect(response_values.dig('comments_count', 'value')).to eq 2
          end
        end
      end
    end
  end
end
