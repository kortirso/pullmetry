# frozen_string_literal: true

describe ProfilesController do
  describe 'GET#show' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      it 'renders show template' do
        create :identity, user: @current_user

        do_request

        expect(response).to render_template :show
      end
    end

    def do_request
      get :show, params: { locale: 'en' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for invalid params' do
        let(:request) {
          patch :update, params: {
            user: {
              'use_work_time' => '1',
              'work_start_time(4i)' => '13',
              'work_start_time(5i)' => '00',
              'work_end_time(4i)' => '13',
              'work_end_time(5i)' => '00'
            },
            locale: 'en'
          }
        }

        it 'does not update user and redirects to profile_path', :aggregate_failures do
          request

          expect(@current_user.reload.work_start_time).to be_nil
          expect(@current_user.work_end_time).to be_nil
          expect(response).to redirect_to profile_path
        end
      end

      context 'for valid params' do
        let(:request) {
          patch :update, params: {
            user: {
              'use_work_time' => '1',
              'work_start_time(4i)' => '12',
              'work_start_time(5i)' => '00',
              'work_end_time(4i)' => '13',
              'work_end_time(5i)' => '00'
            },
            locale: 'en'
          }
        }

        it 'updates regular configuration and redirects to profile_path', :aggregate_failures do
          request

          expect(@current_user.reload.work_start_time).to eq DateTime.new(2000, 1, 1, 12, 0, 0)
          expect(@current_user.work_end_time).to eq DateTime.new(2000, 1, 1, 13, 0, 0)
          expect(response).to redirect_to profile_path
        end
      end
    end

    def do_request
      patch :update, params: {
        user: {
          'use_work_time' => '0',
          'work_start_time(4i)' => '',
          'work_end_time(4i)' => ''
        },
        locale: 'en'
      }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      let!(:company) { create :company, user: @current_user }
      let!(:repository) { create :repository, company: company }

      before do
        create :company
        create :access_token, tokenable: repository
      end

      it 'does not fully destroy user' do
        do_request

        expect(User.find_by(id: @current_user)).to eq @current_user
      end

      it 'destroys user companies and redirects', :aggregate_failures do
        expect { do_request }.to change(@current_user.companies, :count).by(-1)
        expect(response).to redirect_to root_path
      end

      it 'destroys user repositories and redirects', :aggregate_failures do
        expect { do_request }.to change(@current_user.repositories, :count).by(-1)
        expect(response).to redirect_to root_path
      end
    end

    def do_request
      delete :destroy, params: { locale: 'en' }
    end
  end
end
