# frozen_string_literal: true

describe FeedbacksController do
  describe 'GET#show' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      it 'renders show template' do
        get :show

        expect(response).to render_template :show
      end
    end

    def do_request
      get :show
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for invalid params' do
        let(:do_request) { post :create, params: { feedback: { description: '' } } }

        it 'does not create feedback and redirects', :aggregate_failures do
          expect { do_request }.not_to change(@current_user.feedbacks, :count)
          expect(response).to redirect_to feedback_path
        end
      end

      context 'for valid params' do
        it 'creates feedback and redirects', :aggregate_failures do
          expect { do_request }.to change(@current_user.feedbacks, :count).by(1)
          expect(response).to redirect_to profile_path
        end
      end
    end

    def do_request
      post :create, params: { feedback: { description: 'Text' } }
    end
  end
end
