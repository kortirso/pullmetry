# frozen_string_literal: true

describe Companies::ConfigurationsController do
  describe 'GET#edit' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      let!(:company) { create :company }

      sign_in_user

      before do
        group = create :excludes_group, insightable: company
        create :excludes_rule, excludes_group: group
        webhook = create :webhook, company: company
        create :notification, notifyable: company, webhook: webhook
      end

      context 'for not existing company' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing user company' do
        it 'renders access page' do
          get :edit, params: { company_id: company.uuid, locale: 'en' }

          expect(response).to render_template 'shared/access'
        end
      end

      context 'for existing company with user read access' do
        before do
          identity = create :identity, user: @current_user
          entity = create :entity, identity: identity
          create :insight, insightable: company, entity: entity
        end

        it 'renders access page' do
          get :edit, params: { company_id: company.uuid, locale: 'en' }

          expect(response).to render_template 'shared/access'
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
      let!(:company) { create :company, configuration: { insight_ratio_type: 'ratio' } }

      sign_in_user

      context 'for not existing company' do
        it 'renders 404 page' do
          do_request

          expect(response).to render_template 'shared/404'
        end
      end

      context 'for not existing user company' do
        it 'renders access page' do
          patch :update, params: {
            company_id: company.uuid,
            jsonb_columns_configuration: {
              'use_work_time' => '0',
              'work_start_time(4i)' => '',
              'work_end_time(4i)' => ''
            }
          }

          expect(response).to render_template 'shared/access'
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
                'work_start_time(4i)' => '13',
                'work_start_time(5i)' => '00',
                'work_end_time(4i)' => '13',
                'work_end_time(5i)' => '00'
              }
            }
          }

          it 'does not update configuration and redirects', :aggregate_failures do
            request

            configuration = company.reload.configuration

            expect(configuration.work_start_time).to be_nil
            expect(configuration.work_end_time).to be_nil
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
                'work_end_time(5i)' => '00',
                'insight_fields' => {
                  'unknown' => '1',
                  'comments_count' => 2
                },
                'insight_ratio' => '1',
                'insight_ratio_type' => 'change'
              }
            }
          }

          context 'for regular account' do
            it 'updates regular configuration and redirects', :aggregate_failures do
              request

              configuration = company.reload.configuration

              expect(configuration.work_start_time).to eq DateTime.new(2023, 1, 1, 12, 0, 0)
              expect(configuration.work_end_time).to eq DateTime.new(2023, 1, 1, 13, 0, 0)
              expect(configuration.insight_fields).to be_nil
              expect(configuration.insight_ratio).to be_nil
              expect(configuration.insight_ratio_type).to eq 'ratio'
              expect(response).to redirect_to companies_path
            end
          end

          context 'for premium account' do
            before { create :subscription, user: @current_user }

            # rubocop: disable RSpec/ExampleLength
            it 'updates configuration with additional attributes and redirects', :aggregate_failures do
              request

              configuration = company.reload.configuration

              expect(configuration.work_start_time).to eq DateTime.new(2023, 1, 1, 12, 0, 0)
              expect(configuration.work_end_time).to eq DateTime.new(2023, 1, 1, 13, 0, 0)
              expect(configuration.insight_fields.attributes).to eq({
                'comments_count' => true,
                'conventional_comments_count' => nil,
                'reviews_count' => nil,
                'bad_reviews_count' => nil,
                'required_reviews_count' => nil,
                'review_involving' => nil,
                'reviewed_loc' => nil,
                'average_reviewed_loc' => nil,
                'open_pull_requests_count' => nil,
                'average_open_pr_comments' => nil,
                'average_review_seconds' => nil,
                'average_merge_seconds' => nil,
                'changed_loc' => nil,
                'average_changed_loc' => nil,
                'time_since_last_open_pull_seconds' => nil
              })
              expect(configuration.insight_ratio).to be_truthy
              expect(configuration.insight_ratio_type).to eq 'change'
              expect(response).to redirect_to companies_path
            end
            # rubocop: enable RSpec/ExampleLength
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
        }
      }
    end
  end
end
