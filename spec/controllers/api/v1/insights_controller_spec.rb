# frozen_string_literal: true

describe Api::V1::InsightsController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required valid api auth'

    context 'for logged users' do
      let!(:company) { create :company, config: { insight_ratio: true } }
      let!(:user) { create :user }
      let(:api_access_token) { create :api_access_token, user: user }

      before { create :user_subscription, user: user }

      context 'for companies' do
        before do
          insight = create :insight, insightable: company, comments_count: 1
          create :insight, insightable: company, comments_count: 2, previous_date: 1.week.ago, entity: insight.entity
        end

        context 'for unexisting company' do
          it 'returns 404 error' do
            get :index, params: { company_id: 'unexisting', api_access_token: api_access_token.value }

            expect(response).to have_http_status :not_found
          end
        end

        context 'for user company' do
          before { company.update!(user: user) }

          it 'returns data', :aggregate_failures do
            get :index, params: { company_id: company.uuid, api_access_token: api_access_token.value }

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
              get :index, params: { company_id: company.uuid, api_access_token: api_access_token.value }

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
              get :index, params: { company_id: company.uuid, api_access_token: api_access_token.value }

              response_values = response.parsed_body.dig('insights', 0, 'values')

              expect(response).to have_http_status :ok
              expect(response_values.keys).to match_array Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
              expect(response_values.dig('comments_count', 'value')).to eq 1
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
            get :index, params: { repository_id: repository.uuid, api_access_token: api_access_token.value }

            response_values = response.parsed_body.dig('insights', 0, 'values')

            expect(response).to have_http_status :ok
            expect(response_values.keys).to match_array Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
            expect(response_values.dig('comments_count', 'value')).to eq 2
          end
        end
      end
    end

    def do_request(api_access_token=nil)
      get :index, params: { company_id: 'unexisting', api_access_token: api_access_token }.compact
    end
  end
end
