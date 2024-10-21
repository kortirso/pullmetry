# frozen_string_literal: true

describe Frontend::WorkTimesController do
  let!(:user) { create :user }
  let!(:user_session) { create :user_session, user: user }
  let(:access_token) { Authkeeper::GenerateTokenService.new.call(user_session: user_session)[:result] }

  describe 'POST#create' do
    it_behaves_like 'required frontend auth'

    context 'for logged users' do
      context 'for invalid params' do
        let(:request) {
          post :create, params: {
            starts_at: '13:00',
            ends_at: '13:00',
            pullmetry_access_token: access_token
          }
        }

        it 'does not create work time', :aggregate_failures do
          expect { request }.not_to change(WorkTime, :count)
          expect(response).to have_http_status :ok
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: {
            starts_at: '12:00',
            ends_at: '13:00',
            pullmetry_access_token: access_token
          }
        }

        it 'creates work time for user', :aggregate_failures do
          expect { request }.to change(WorkTime, :count).by(1)
          expect(user.work_time.starts_at).to eq '12:00'
          expect(user.work_time.ends_at).to eq '13:00'
          expect(response).to have_http_status :created
        end
      end

      context 'for company' do
        let!(:company) { create :company, user: user }

        let(:request) {
          post :create, params: {
            company_id: company_id,
            starts_at: '12:00',
            ends_at: '13:00',
            pullmetry_access_token: access_token
          }
        }

        context 'for unexisting company' do
          let(:company_id) { 'unexisting' }

          it 'does not create work time', :aggregate_failures do
            expect { request }.not_to change(WorkTime, :count)
            expect(response).to have_http_status :not_found
          end
        end

        context 'for existing company' do
          let(:company_id) { company.uuid }

          it 'does not create work time', :aggregate_failures do
            expect { request }.to change(WorkTime, :count).by(1)
            expect(response).to have_http_status :created
          end
        end
      end
    end

    def do_request
      post :create, params: {
        starts_at: '12:00',
        ends_at: '13:00',
        timezone: '0'
      }
    end
  end
end
