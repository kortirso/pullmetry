# frozen_string_literal: true

describe Companies::ConfigurationsController do
  describe 'GET#edit' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      let!(:company) { create :company }

      sign_in_user

      context 'for not existing company' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing user company' do
        it 'renders 404 page' do
          get :edit, params: { company_id: company.uuid, locale: 'en' }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user company' do
        before { company.update!(user: @current_user) }

        it 'renders new template' do
          get :edit, params: { company_id: company.uuid, locale: 'en' }

          expect(response).to render_template :edit
        end
      end
    end

    def do_request
      get :edit, params: { company_id: 'unexisting', locale: 'en' }
    end
  end

  describe 'PATCH#update' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      let!(:company) { create :company }

      sign_in_user

      context 'for not existing company' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing user company' do
        it 'renders 404 page' do
          patch :update, params: {
            company_id: company.uuid,
            jsonb_columns_configuration: {
              'use_work_time' => '0',
              'work_start_time(4i)' => '',
              'work_end_time(4i)' => ''
            },
            locale: 'en'
          }

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for existing user company' do
        before { company.update!(user: @current_user) }

        context 'for invalid params' do
          let(:request) {
            patch :update, params: {
              company_id: company.uuid,
              jsonb_columns_configuration: {
                'use_work_time' => '1',
                'work_start_time(4i)' => '14',
                'work_start_time(5i)' => '00',
                'work_end_time(4i)' => '13',
                'work_end_time(5i)' => '00'
              },
              locale: 'en'
            }
          }

          it 'does not update configuration', :aggregate_failures do
            request

            configuration = company.reload.configuration

            expect(configuration.work_start_time).to be_nil
            expect(configuration.work_end_time).to be_nil
          end

          it 'redirects to edit_company_configuration_path' do
            request

            expect(response).to redirect_to edit_company_configuration_path(company.uuid)
          end
        end

        context 'for valid params' do
          let(:request) {
            patch :update, params: {
              company_id: company.uuid,
              jsonb_columns_configuration: {
                'use_work_time' => '1',
                'work_start_time(4i)' => '12',
                'work_start_time(5i)' => '00',
                'work_end_time(4i)' => '13',
                'work_end_time(5i)' => '00'
              },
              locale: 'en'
            }
          }

          it 'updates configuration', :aggregate_failures do
            request

            configuration = company.reload.configuration

            expect(configuration.work_start_time).to eq DateTime.new(2023, 1, 1, 12, 0, 0)
            expect(configuration.work_end_time).to eq DateTime.new(2023, 1, 1, 13, 0, 0)
          end

          it 'redirects to companies_path' do
            request

            expect(response).to redirect_to companies_path
          end
        end
      end
    end

    def do_request
      patch :update, params: {
        company_id: 'unexisting',
        jsonb_columns_configuration: {
          'use_work_time' => '0',
          'work_start_time(4i)' => '',
          'work_end_time(4i)' => ''
        },
        locale: 'en'
      }
    end
  end
end