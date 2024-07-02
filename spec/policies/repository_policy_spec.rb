# frozen_string_literal: true

describe RepositoryPolicy do
  let!(:user) { create :user }
  let!(:company1) { create :company, user: user }
  let!(:company2) { create :company }
  let!(:repository1) { create :repository, company: company1 }
  let!(:repository2) { create :repository, company: company2 }

  describe '#update?' do
    context 'for not user repository' do
      let(:policy) { described_class.new(repository2, user: user) }

      it 'returns false' do
        expect(policy_access).to be_falsy
      end

      context 'when user is admin' do
        before { user.update!(role: 'admin') }

        it 'returns false' do
          expect(policy_access).to be_falsy
        end
      end
    end

    context 'for user repository' do
      let(:policy) { described_class.new(repository1, user: user) }

      it 'returns true' do
        expect(policy_access).to be_truthy
      end
    end

    context 'for company with read access' do
      let(:policy) { described_class.new(repository2, user: user) }

      before { create :companies_user, company: company2, user: user, access: Companies::User::READ }

      it 'returns false' do
        expect(policy_access).to be_falsy
      end
    end

    context 'for company with write access' do
      let(:policy) { described_class.new(repository2, user: user) }

      before { create :companies_user, company: company2, user: user, access: Companies::User::WRITE }

      it 'returns true' do
        expect(policy_access).to be_truthy
      end
    end

    def policy_access
      policy.update?
    end
  end
end
