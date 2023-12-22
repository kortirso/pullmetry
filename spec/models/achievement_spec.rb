# frozen_string_literal: true

describe Achievement do
  describe 'awarding' do
    let!(:user) { create :user }
    let!(:identity) { create :identity, user: user }
    let!(:entity) { create :entity, identity: identity }
    let!(:company) { create :company }

    before do
      create :insight,
             entity: entity,
             insightable: company,
             comments_count: 3,
             reviews_count: 2,
             open_pull_requests_count: 1
    end

    context 'for comment_create' do
      before do
        create :kudos_achievement, award_name: 'comment_create', rank: 1
        create :kudos_achievement, award_name: 'comment_create', rank: 2, points: 10
      end

      it 'awards user' do
        expect { described_class.award(:comment_create, user) }.to(
          change(Kudos::Users::Achievement, :count).by(1)
        )
      end
    end

    context 'for review_create' do
      before do
        create :kudos_achievement, award_name: 'review_create', rank: 1
        create :kudos_achievement, award_name: 'review_create', rank: 2, points: 10
      end

      it 'awards user' do
        expect { described_class.award(:review_create, user) }.to(
          change(Kudos::Users::Achievement, :count).by(1)
        )
      end
    end

    context 'for pull_request_create' do
      before do
        create :kudos_achievement, award_name: 'pull_request_create', rank: 1
        create :kudos_achievement, award_name: 'pull_request_create', rank: 2, points: 10
      end

      it 'awards user' do
        expect { described_class.award(:pull_request_create, user) }.to(
          change(Kudos::Users::Achievement, :count).by(1)
        )
      end
    end
  end
end
