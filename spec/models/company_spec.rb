# frozen_string_literal: true

describe Company do
  it 'factory should be valid' do
    company = build :company

    expect(company).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:repositories).dependent(:destroy) }
    it { is_expected.to have_one(:access_token).dependent(:destroy) }
    it { is_expected.to have_many(:insights).dependent(:destroy) }
    it { is_expected.to have_many(:ignores).dependent(:destroy) }
    it { is_expected.to have_many(:webhooks).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
    it { is_expected.to have_many(:excludes_groups).class_name('Excludes::Group').dependent(:destroy) }
    it { is_expected.to have_many(:invites).dependent(:destroy) }

    it {
      is_expected.to have_many(:pull_requests_comments).class_name('::PullRequests::Comment').through(:repositories)
    }

    it {
      is_expected.to have_many(:pull_requests_reviews).class_name('::PullRequests::Review').through(:repositories)
    }

    it { is_expected.to have_many(:companies_users).class_name('Companies::User').dependent(:destroy) }
  end

  describe '#find_fetch_period' do
    let!(:company) { create :company }

    it 'returns default fetch period' do
      expect(company.find_fetch_period).to eq Insight::FETCH_DAYS_PERIOD
    end

    context 'for existing fetch_period in configuration' do
      before do
        company.configuration.fetch_period = 61
        company.save!
      end

      context 'for regular account' do
        it 'returns minimum period' do
          expect(company.find_fetch_period).to eq Insight::FETCH_DAYS_PERIOD
        end

        context 'when fetch_period is less than default' do
          before do
            company.configuration.fetch_period = 29
            company.save!
          end

          it 'returns full period' do
            expect(company.find_fetch_period).to eq 29
          end
        end
      end

      context 'for premium account' do
        before { create :user_subscription, user: company.user }

        it 'returns full period' do
          expect(company.find_fetch_period).to eq 61
        end
      end
    end
  end

  describe '#user_ids' do
    let!(:company) { create :company }
    let!(:entity) { create :entity }
    let!(:identity) { create :identity }
    let!(:insight) { create :insight, insightable: company, entity: entity, previous_date: DateTime.now, hidden: true }

    context 'for not actual insight' do
      it 'returns empty result' do
        expect(company.user_ids).to be_empty
      end

      context 'for actual insight' do
        before { insight.update!(previous_date: nil) }

        it 'returns empty result' do
          expect(company.user_ids).to be_empty
        end

        context 'for visible insight' do
          before { insight.update!(hidden: false) }

          it 'returns empty result' do
            expect(company.user_ids).to be_empty
          end

          context 'for connected entity with user' do
            before { entity.update!(identity: identity) }

            it 'returns user id' do
              expect(company.user_ids).to eq([identity.user_id])
            end
          end
        end
      end
    end
  end
end
