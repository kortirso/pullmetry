# frozen_string_literal: true

describe Frontend::Users::VacationsController do
  let!(:user) { create :user }
  let!(:user_session) { create :user_session, user: user }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result] }

  describe 'POST#create' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      context 'for invalid params' do
        let(:request) {
          post :create, params: {
            user_vacation: { start_time: '03-01-2023', end_time: '02-01-2023' }, pullmetry_access_token: access_token
          }
        }

        it 'does not create vacation', :aggregate_failures do
          expect { request }.not_to change(User::Vacation, :count)
          expect(response.parsed_body['errors']).not_to be_nil
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: {
            user_vacation: { start_time: '01-01-2023', end_time: '02-01-2023' }, pullmetry_access_token: access_token
          }
        }

        it 'creates vacation', :aggregate_failures do
          expect { request }.to change(user.vacations, :count).by(1)
          expect(response.parsed_body['errors']).to be_nil
        end
      end
    end

    def do_request
      post :create, params: { user_vacation: { start_time: '', end_time: '' } }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      let!(:user_vacation) { create :user_vacation }
      let(:request) { delete :destroy, params: { id: user_vacation.id, pullmetry_access_token: access_token } }

      context 'for not user vacation' do
        it 'does not destroy vacation', :aggregate_failures do
          expect { request }.not_to change(User::Vacation, :count)
          expect(response).to have_http_status :not_found
        end
      end

      context 'for user vacation' do
        before { user_vacation.update!(user: user) }

        it 'destroys vacation', :aggregate_failures do
          expect { request }.to change(User::Vacation, :count).by(-1)
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
