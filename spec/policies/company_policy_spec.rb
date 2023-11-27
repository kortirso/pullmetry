# frozen_string_literal: true

describe CompanyPolicy do
  let!(:user) { create :user }
  let!(:company1) { create :company, user: user }
  let!(:company2) { create :company }

  describe '#update?' do
    context 'for not user company' do
      let(:policy) { described_class.new(company2, user: user) }

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

    context 'for user company' do
      let(:policy) { described_class.new(company1, user: user) }

      it 'returns true' do
        expect(policy_access).to be_truthy
      end
    end

    def policy_access
      policy.update?
    end
  end
end
