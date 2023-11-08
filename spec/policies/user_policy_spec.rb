# frozen_string_literal: true

describe UserPolicy do
  let!(:user) { create :user }

  describe '#create_repository?' do
    context 'when user does not have company' do
      it 'returns false' do
        expect(policy_access).to be_falsy
      end

      context 'when user has company' do
        let!(:company) { create :company, user: user }

        context 'for regular user' do
          context 'when user does not have too much repositories' do
            it 'returns true' do
              expect(policy_access).to be_truthy
            end
          end

          context 'when user has too much repositories' do
            before { create_list :repository, Subscription::FREE_REPOSITORIES_AMOUNT, company: company }

            it 'returns false' do
              expect(policy_access).to be_falsy
            end
          end
        end

        context 'when user is admin' do
          before { user.update!(role: 'admin') }

          it 'returns true' do
            expect(policy_access).to be_truthy
          end
        end
      end
    end

    def policy_access
      described_class.new(user, user: user).create_repository?
    end
  end
end
