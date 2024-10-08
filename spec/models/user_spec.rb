# frozen_string_literal: true

describe User do
  it 'factory should be valid' do
    user = build :user

    expect(user).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:sessions).class_name('::User::Session').dependent(:destroy) }
    it { is_expected.to have_many(:invites).dependent(:destroy) }
    it { is_expected.to have_many(:receive_invites).class_name('Invite').dependent(:nullify) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_many(:companies).dependent(:destroy) }
    it { is_expected.to have_many(:identities).dependent(:destroy) }
    it { is_expected.to have_many(:subscriptions).dependent(:destroy) }
    it { is_expected.to have_many(:vacations).dependent(:destroy) }
    it { is_expected.to have_many(:api_access_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:companies_users).class_name('Companies::User').dependent(:destroy) }
  end

  describe '.premium?' do
    let!(:user) { create :user }

    context 'without subscriptions' do
      it 'returns false' do
        expect(user.premium?).to be_falsy
      end
    end

    context 'with subscription' do
      before { create :user_subscription, user: user, start_time: DateTime.now + 1.minute }

      it 'returns true' do
        expect(user.premium?).to be_truthy
      end
    end
  end

  describe '.available_companies' do
    let!(:user) { create :user }
    let!(:company1) { create :company, user: user }
    let!(:company2) { create :company }
    let!(:company3) { create :company }
    let!(:company4) { create :company }
    let!(:company5) { create :company }

    before do
      create :company
      identity = create :identity, user: user
      entity = create :entity, identity: identity
      create :insight, insightable: company2, entity: entity
      create :insight, insightable: company3, entity: entity, hidden: true
      create :invite, inviteable: company4, receiver: user
      create :companies_user, company: company5, user: user
    end

    it 'returns 3 available companies' do
      expect(user.available_companies.ids).to contain_exactly(company1.id, company2.id, company5.id)
    end
  end

  describe '.available_repositories' do
    let!(:user) { create :user }
    let!(:company) { create :company, user: user }
    let!(:repository1) { create :repository, company: company }
    let!(:repository2) { create :repository }

    before do
      create :repository
      identity = create :identity, user: user
      entity = create :entity, identity: identity
      create :insight, insightable: repository2.company, entity: entity
    end

    it 'returns 2 available repositories' do
      expect(user.available_repositories.ids).to contain_exactly(repository1.id, repository2.id)
    end
  end
end
