# frozen_string_literal: true

describe VacationsController do
  describe 'GET#new' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      it 'renders new template' do
        do_request

        expect(response).to render_template :new
      end
    end

    def do_request
      get :new, params: { locale: 'en' }
    end
  end

  describe 'POST#create' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      context 'for invalid params' do
        let(:request) {
          post :create, params: {
            vacation: {
              'start_time(1i)' => '2023',
              'start_time(2i)' => '01',
              'start_time(3i)' => '03',
              'end_time(1i)' => '2023',
              'end_time(2i)' => '01',
              'end_time(3i)' => '02'
            },
            locale: 'en'
          }
        }

        it 'does not create vacation' do
          expect { request }.not_to change(Vacation, :count)
        end

        it 'redirects to new_vacation_path' do
          request

          expect(response).to redirect_to new_vacation_path
        end
      end

      context 'for valid params' do
        let(:request) {
          post :create, params: {
            vacation: {
              'start_time(1i)' => '2023',
              'start_time(2i)' => '01',
              'start_time(3i)' => '01',
              'end_time(1i)' => '2023',
              'end_time(2i)' => '01',
              'end_time(3i)' => '02'
            },
            locale: 'en'
          }
        }

        it 'creates vacation' do
          expect { request }.to change(@current_user.vacations, :count).by(1)
        end

        it 'redirects to profile_path' do
          request

          expect(response).to redirect_to profile_path
        end
      end
    end

    def do_request
      post :create, params: {
        vacation: {
          'start_time(1i)' => '',
          'end_time(1i)' => ''
        },
        locale: 'en'
      }
    end
  end

  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      let!(:vacation) { create :vacation }
      let(:request) { delete :destroy, params: { id: vacation.id, locale: 'en' } }

      context 'for not user vacation' do
        it 'destroys vacation and redirects', :aggregate_failures do
          expect { request }.not_to change(Vacation, :count)
          expect(response).to redirect_to profile_path
        end
      end

      context 'for user vacation' do
        before { vacation.update!(user: @current_user) }

        it 'destroys vacation and redirects', :aggregate_failures do
          expect { request }.to change(Vacation, :count).by(-1)
          expect(response).to redirect_to profile_path
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting', locale: 'en' }
    end
  end
end
