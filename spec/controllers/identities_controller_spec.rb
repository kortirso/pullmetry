# frozen_string_literal: true

describe IdentitiesController do
  describe 'DELETE#destroy' do
    it_behaves_like 'required auth'

    context 'for logged users' do
      sign_in_user

      let!(:identity) { create :identity, user: @current_user }
      let(:request) { delete :destroy, params: { id: identity.id } }

      context 'for not user identity' do
        it 'does not destroy identity', :aggregate_failures do
          expect { request }.not_to change(Identity, :count)
          expect(response).to redirect_to profile_path
        end
      end

      context 'for user identity' do
        it 'does not destroy identity', :aggregate_failures do
          expect { request }.not_to change(Identity, :count)
          expect(response).to redirect_to profile_path
        end

        context 'for 2 identities' do
          before { create :identity, provider: Providerable::GITLAB, user: @current_user }

          it 'destroys identity', :aggregate_failures do
            ap Identity.all

            request

            expect(Identity.find_by(id: identity.id)).to be_nil
            expect(response).to redirect_to profile_path
          end
        end
      end
    end

    def do_request
      delete :destroy, params: { id: 'unexisting' }
    end
  end
end
