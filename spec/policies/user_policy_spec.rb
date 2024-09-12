# frozen_string_literal: true

describe UserPolicy do
  let(:amount) { nil }
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

          context 'for available transfer' do
            let(:amount) { 5 }

            it 'returns true' do
              expect(policy_access).to be_truthy
            end
          end

          context 'for unavailable transfer' do
            let(:amount) { 6 }

            it 'returns false' do
              expect(policy_access).to be_falsy
            end
          end

          context 'when user has too much repositories' do
            before { create_list :repository, User::Subscription::FREE_REPOSITORIES_AMOUNT, company: company }

            it 'returns false' do
              expect(policy_access).to be_falsy
            end

            context 'for premium account' do
              before { create :user_subscription, user: user }

              it 'returns true' do
                expect(policy_access).to be_truthy
              end
            end
          end

          context 'for premium account' do
            context 'when user has too much repositories' do
              before do
                create :user_subscription, user: user

                allow(user).to receive(:plan_settings).and_return({ repositories_limit: 0 })
              end

              it 'returns false' do
                expect(policy_access).to be_falsy
              end
            end

            context 'for unlimited subscription' do
              before { create :user_subscription, user: user, plan: User::Subscription::UNLIMITED }

              it 'returns true' do
                expect(policy_access).to be_truthy
              end
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
      described_class.new(user, user: user, amount: amount).create_repository?
    end
  end
end
