# frozen_string_literal: true

describe Frontend::ProfilesController do
  let!(:user) { create :user }
  let!(:users_session) { create :users_session, user: user }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(users_session: users_session)[:result] }

  describe 'PATCH#update' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      context 'for invalid params' do
        let(:request) {
          patch :update, params: {
            user: {
              start_time: '13:00',
              end_time: '13:00'
            },
            pullmetry_access_token: access_token
          }
        }

        it 'does not update user and redirects to profile_path', :aggregate_failures do
          request

          expect(user.reload.start_time).to be_nil
          expect(user.end_time).to be_nil
          expect(response).to have_http_status :ok
        end
      end

      context 'for valid params' do
        let(:request) {
          patch :update, params: {
            user: {
              start_time: '12:00',
              end_time: '13:00'
            },
            pullmetry_access_token: access_token
          }
        }

        it 'updates regular configuration and redirects to profile_path', :aggregate_failures do
          request

          expect(user.reload.start_time).to eq '12:00'
          expect(user.end_time).to eq '13:00'
          expect(response).to have_http_status :ok
        end
      end
    end

    def do_request
      patch :update, params: {
        user: {
          start_time: '12:00',
          end_time: '13:00'
        }
      }
    end
  end
end
