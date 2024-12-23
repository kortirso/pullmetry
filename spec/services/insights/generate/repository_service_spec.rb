# frozen_string_literal: true

describe Insights::Generate::RepositoryService, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable) }

  let!(:repository) { create :repository }
  let!(:pr2) { create :pull_request, repository: repository, entity: entity1, changed_loc: 13 }
  let!(:pr3) {
    create :pull_request, repository: repository, pull_merged_at: 10.seconds.after, entity: entity2, changed_loc: 11
  }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }
  let(:insightable) { repository }

  before do
    create :pull_request, repository: repository, entity: entity1, changed_loc: 12
    create :pull_request_comment, entity: entity1, pull_request: pr3, comment_created_at: 1.minute.after
    create :pull_request_comment, entity: entity2, pull_request: pr2, comment_created_at: 2.minutes.after

    create :pull_request_review,
           state: PullRequest::Review::COMMENTED,
           entity: entity1,
           pull_request: pr3,
           review_created_at: 1.minute.after

    create :pull_request_review,
           entity: entity2,
           pull_request: pr2,
           review_created_at: 10.seconds.after,
           required: true
  end

  context 'for unexisting insights' do
    it 'creates 2 insights' do
      expect { service_call }.to change(insightable.insights.visible, :count).by(2)
    end

    it 'creates 1 repository insight' do
      expect { service_call }.to change(insightable.repository_insights, :count).by(1)
    end

    context 'for private company' do
      before do
        insightable.company.config.private = true
        insightable.company.save!
      end

      it 'creates 2 insights' do
        expect { service_call }.to change(insightable.insights.hidden, :count).by(2)
      end
    end
  end

  context 'for existing old insight' do
    let!(:entity3) { create :entity, external_id: '3' }

    before { create :insight, insightable: insightable, entity: entity3, comments_count: 1 }

    it 'creates 2 new insights and destroys old insight', :aggregate_failures do
      service_call

      expect(insightable.insights.pluck(:entity_id)).to contain_exactly(entity1.id, entity2.id)
      expect(insightable.insights.where(entity_id: entity3.id)).to be_empty
    end
  end

  context 'for existing insight' do
    let!(:insight) { create :insight, insightable: insightable, entity: entity1, comments_count: 0 }

    it 'insight has default list of attributes', :aggregate_failures do
      expect { service_call }.to change(insightable.insights, :count).by(1)

      last_insight = Insight.last

      expect(last_insight.entity).to eq entity2
      expect(last_insight.required_reviews_count).to eq 0
      expect(last_insight.reviews_count).to eq 1
      expect(last_insight.average_review_seconds).not_to eq 0
      expect(last_insight.comments_count).to eq 1
      expect(last_insight.open_pull_requests_count).to eq 1
      expect(last_insight.average_merge_seconds).to eq 0
      # updates existing insight
      expect(insight.reload.comments_count).to eq 2
    end

    context 'for premium account with ratio settings' do
      before do
        create :user_subscription, user: repository.company.user
        repository.company.config.insight_ratio = true
        repository.company.save!
      end

      context 'without PRs at previous period' do
        it 'insight has default list of attributes', :aggregate_failures do
          expect { service_call }.to change(insightable.insights, :count).by(3)

          last_insight = Insight.actual.last

          expect(last_insight.required_reviews_count).to eq 0
          expect(last_insight.reviews_count).to eq 1
          expect(last_insight.average_review_seconds).not_to eq 0
          expect(last_insight.comments_count).to eq 1
          expect(last_insight.open_pull_requests_count).to eq 1
          expect(last_insight.average_merge_seconds).to eq 0
        end

        it 'creates repository insights', :aggregate_failures do
          expect { service_call }.to change(insightable.repository_insights, :count).by(2)

          last_insight = Repositories::Insight.actual.last

          expect(last_insight.open_pull_requests_count).to eq 3
          expect(last_insight.commented_pull_requests_count).to eq 2
          expect(last_insight.reviewed_pull_requests_count).to eq 1
          expect(last_insight.merged_pull_requests_count).to eq 1
          expect(last_insight.average_comment_time).to eq 35
          expect(last_insight.average_review_time).to eq 10
          expect(last_insight.average_merge_time).to eq 10
          expect(last_insight.comments_count).to eq 3
          expect(last_insight.average_comments_count).to eq 1
          expect(last_insight.changed_loc).to eq 36
          expect(last_insight.average_changed_loc).to eq 12
        end
      end

      context 'with PRs at previous period' do
        let(:old_pr2) {
          create :pull_request,
                 repository: repository,
                 pull_created_at: 40.days.ago,
                 pull_merged_at: 35.days.ago,
                 entity: entity2
        }

        before do
          old_pr1 =
            create :pull_request,
                   repository: repository,
                   pull_created_at: 40.days.ago,
                   pull_merged_at: 35.days.ago,
                   entity: entity1

          create_list :pull_request_comment, 2, entity: entity2, pull_request: old_pr1

          old_pr3 =
            create :pull_request,
                   repository: repository,
                   pull_created_at: 40.days.ago,
                   pull_merged_at: 35.days.ago,
                   entity: entity1

          create :pull_request_review, entity: entity2, pull_request: old_pr3, review_created_at: 39.days.ago
        end

        context 'with default insight attributes' do
          it 'insight has default list of attributes', :aggregate_failures do
            expect { service_call }.to change(insightable.insights, :count).by(3)

            last_insight = Insight.actual.last

            expect(last_insight.required_reviews_count).to eq 0
            expect(last_insight.reviews_count).to eq 1
            expect(last_insight.average_review_seconds).not_to eq 0
            expect(last_insight.comments_count).to eq 1
            expect(last_insight.open_pull_requests_count).to eq 1
            expect(last_insight.review_involving).to be_nil
          end
        end

        context 'with custom insight attributes' do
          before do
            create :pull_request_comment, entity: entity1, pull_request: pr3
            create :pull_request_comment, entity: entity1, pull_request: pr3
            create :pull_request_comment, entity: entity1, pull_request: old_pr2

            repository.company.config.insight_fields = {
              comments_count: true,
              reviews_count: true,
              required_reviews_count: true,
              open_pull_requests_count: true,
              average_open_pr_comments: true,
              average_review_seconds: true,
              average_merge_seconds: true,
              review_involving: true,
              changed_loc: true,
              average_changed_loc: true,
              average_reviewed_loc: true
            }
            repository.company.save!
          end

          it 'insight has full list of attributes', :aggregate_failures do
            expect { service_call }.to change(insightable.insights, :count).by(3)

            last_insight = Insight.actual.last

            expect(last_insight.required_reviews_count).to eq 1
            expect(last_insight.reviews_count).to eq 1
            expect(last_insight.average_review_seconds).not_to eq 0
            expect(last_insight.comments_count).to eq 1
            expect(last_insight.open_pull_requests_count).to eq 1
            expect(last_insight.average_merge_seconds).to eq 10
            expect(last_insight.average_open_pr_comments).to eq 4
            expect(last_insight.review_involving).to eq 50
            expect(last_insight.changed_loc).to eq 11
            expect(last_insight.average_changed_loc).to eq 11
            expect(last_insight.average_reviewed_loc).to eq 13
          end
        end
      end
    end
  end
end
