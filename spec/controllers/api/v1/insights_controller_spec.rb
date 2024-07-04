# frozen_string_literal: true

describe Api::V1::InsightsController do
  describe 'GET#index' do
    it_behaves_like 'required api auth'
    it_behaves_like 'required valid api auth'

    context 'for logged users' do
      let!(:company) { create :company, configuration: { insight_ratio: true } }
      let!(:user) { create :user }
      let(:api_access_token) { create :api_access_token, user: user }

      before { create :subscription, user: user }

      context 'for companies' do
        before do
          insight = create :insight, insightable: company, comments_count: 1
          create :insight, insightable: company, comments_count: 2, previous_date: 1.week.ago, entity: insight.entity
        end

        context 'for user company' do
          before { company.update!(user: user) }

          it 'returns data', :aggregate_failures do
            get :index, params: { company_id: company.uuid, api_access_token: api_access_token.value }

            response_values = response.parsed_body.dig('insights', 'data', 0, 'attributes', 'values')

            expect(response).to have_http_status :ok
            expect(response_values.keys).to eq Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
            expect(response_values.dig('comments_count', 'value')).to eq 1
          end

          context 'for selected insight fields' do
            before do
              company.configuration.insight_fields = { comments_count: true, reviews_count: true }
              company.save!
            end

            it 'returns data', :aggregate_failures do
              get :index, params: { company_id: company.uuid, api_access_token: api_access_token.value }

              response_values = response.parsed_body.dig('insights', 'data', 0, 'attributes', 'values')

              expect(response).to have_http_status :ok
              expect(response_values.keys).to contain_exactly('comments_count', 'reviews_count')
              expect(response_values.dig('comments_count', 'value')).to eq 1
            end
          end

          context 'for change ratio' do
            before do
              company.configuration.insight_ratio_type = 'change'
              company.save!
            end

            it 'returns data', :aggregate_failures do
              get :index, params: { company_id: company.uuid, api_access_token: api_access_token.value }

              response_values = response.parsed_body.dig('insights', 'data', 0, 'attributes', 'values')

              expect(response).to have_http_status :ok
              expect(response_values.keys).to eq Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
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

            response_values = response.parsed_body.dig('insights', 'data', 0, 'attributes', 'values')

            expect(response).to have_http_status :ok
            expect(response_values.keys).to eq Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
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
