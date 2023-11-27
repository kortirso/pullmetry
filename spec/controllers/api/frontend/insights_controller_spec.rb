# frozen_string_literal: true

describe Api::Frontend::InsightsController do
  describe 'GET#index' do
    context 'for logged users' do
      let!(:company) { create :company }
      let!(:user) { create :user }
      let(:access_token) { Auth::GenerateTokenService.new.call(user: user)[:result] }

      context 'for companies' do
        before { create :insight, insightable: company, comments_count: 1 }

        context 'for user company' do
          before { company.update!(user: user) }

          it 'returns data', :aggregate_failures do
            get :index, params: { company_id: company.uuid, auth_token: access_token }

            response_values = response.parsed_body.dig('insights', 'data', 0, 'attributes', 'values')

            expect(response).to have_http_status :ok
            expect(response_values.keys).to eq Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
            expect(response_values.dig('comments_count', 'value')).to eq 1
          end
        end
      end

      context 'for repositories' do
        let!(:repository) { create :repository, company: company }

        before { create :insight, insightable: repository, comments_count: 2 }

        context 'for user company' do
          before { company.update!(user: user) }

          it 'returns data', :aggregate_failures do
            get :index, params: { repository_id: repository.uuid, auth_token: access_token }

            response_values = response.parsed_body.dig('insights', 'data', 0, 'attributes', 'values')

            expect(response).to have_http_status :ok
            expect(response_values.keys).to eq Insight::DEFAULT_ATTRIBUTES.map(&:to_s)
            expect(response_values.dig('comments_count', 'value')).to eq 2
          end
        end
      end
    end
  end
end
