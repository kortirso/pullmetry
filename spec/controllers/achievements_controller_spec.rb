# frozen_string_literal: true

describe AchievementsController do
  describe 'GET#show' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      let!(:kudos_achievement) { create :kudos_achievement }

      sign_in_user

      context 'without achievements' do
        it 'renders show template' do
          do_request

          expect(response).to render_template :show
        end
      end

      context 'with achievements' do
        before do
          create :kudos_users_achievement, kudos_achievement: kudos_achievement, user: @current_user
        end

        it 'renders show template' do
          do_request

          expect(response).to render_template :show
        end

        context 'with filtering by unexisting group' do
          it 'renders show template' do
            get :show, params: { locale: 'en', group: 1 }

            expect(response).to render_template :show
          end
        end

        context 'with filtering by existing group' do
          it 'renders show template' do
            get :show, params: { locale: 'en', group: kudos_achievement.kudos_achievement_group_id }

            expect(response).to render_template :show
          end
        end
      end
    end

    def do_request
      get :show, params: { locale: 'en' }
    end
  end
end
