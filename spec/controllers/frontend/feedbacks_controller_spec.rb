# frozen_string_literal: true

describe Frontend::FeedbacksController do
  describe 'POST#create' do
    let(:delivery_service) { double }

    before do
      allow(AdminDelivery).to receive(:with).and_return(delivery_service)
      allow(delivery_service).to receive(:feedback_created).and_return(delivery_service)
      allow(delivery_service).to receive(:deliver_later)
    end

    context 'for logged users' do
      let!(:user) { create :user }
      let!(:user_session) { create :user_session, user: user }
      let(:access_token) { Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result] }

      context 'for invalid params' do
        let(:request) { post :create, params: { feedback: { title: '', description: '' }, pullmetry_access_token: access_token } }

        it 'does not create feedback', :aggregate_failures do
          expect { request }.not_to change(Feedback, :count)
          expect(response).to have_http_status :ok
          expect(response.parsed_body.dig('errors', 0)).to eq 'Description must be filled'
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: { feedback: { title: 'Title', description: 'Text' }, pullmetry_access_token: access_token }
        }

        it 'creates feedback', :aggregate_failures do
          expect { request }.to change(user.feedbacks, :count).by(1)
          expect(response).to have_http_status :ok
          expect(response.parsed_body['errors']).to be_nil
        end
      end
    end
  end
end
