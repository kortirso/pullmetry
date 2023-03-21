# frozen_string_literal: true

describe Insights::GenerateService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:repository) { create :repository }
  let!(:pr2) { create :pull_request, repository: repository, entity: entity1 }
  let!(:pr3) { create :pull_request, repository: repository, pull_merged_at: 10.seconds.after, entity: entity2 }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }
  let!(:pr_entity1) { create :pull_requests_entity, pull_request: pr3, entity: entity1 }

  before do
    create :pull_request, repository: repository, entity: entity1
    pr_entity2 = create :pull_requests_entity, pull_request: pr2, entity: entity2
    create :pull_requests_comment, pull_requests_entity: pr_entity1
    create :pull_requests_comment, pull_requests_entity: pr_entity2
    create :pull_requests_review, pull_requests_entity: pr_entity2, review_created_at: 10.seconds.after
  end

  context 'for repository insightable' do
    let(:insightable) { repository }

    context 'for unexisting insights' do
      it 'creates 2 insights' do
        expect { service_call }.to change(insightable.insights, :count).by(2)
      end
    end

    context 'for existing old insight' do
      let!(:entity3) { create :entity, external_id: '3' }

      before { create :insight, insightable: insightable, entity: entity3, comments_count: 1 }

      it 'creates 2 new insights' do
        service_call

        expect(insightable.insights.pluck(:entity_id)).to contain_exactly(entity1.id, entity2.id)
      end

      it 'destroys old insight' do
        service_call

        expect(insightable.insights.where(entity_id: entity3.id)).to be_empty
      end
    end

    context 'for existing insight' do
      let!(:insight) { create :insight, insightable: insightable, entity: entity1, comments_count: 0 }

      it 'creates 1 insight' do
        expect { service_call }.to change(insightable.insights, :count).by(1)
      end

      it 'insight has default list of attributes', :aggregate_failures do
        service_call

        last_insight = Insight.last

        expect(last_insight.entity).to eq entity2
        expect(last_insight.required_reviews_count).to eq 1
        expect(last_insight.reviews_count).to eq 1
        expect(last_insight.average_review_seconds).not_to eq 0
        expect(last_insight.comments_count).to eq 1
        expect(last_insight.required_reviews_count_ratio).to be_nil
        expect(last_insight.reviews_count_ratio).to be_nil
        expect(last_insight.average_review_seconds_ratio).to be_nil
        expect(last_insight.comments_count_ratio).to be_nil
        # entity2 has 1 open pull request, but this attribute is disabled -> result is 0
        expect(last_insight.open_pull_requests_count).to eq 0
        expect(last_insight.average_merge_seconds).to eq 0
      end

      it 'updates existing insight' do
        service_call

        expect(insight.reload.comments_count).to eq 1
      end

      context 'for premium account with ratio settings' do
        before do
          create :subscription, user: repository.company.user
          repository.company.configuration.insight_ratio = true
          repository.company.save!
        end

        context 'without PRs at previous period' do
          it 'creates 1 insight' do
            expect { service_call }.to change(insightable.insights, :count).by(1)
          end

          it 'insight has default list of attributes', :aggregate_failures do
            service_call

            last_insight = Insight.last

            expect(last_insight.required_reviews_count).to eq 1
            expect(last_insight.reviews_count).to eq 1
            expect(last_insight.average_review_seconds).not_to eq 0
            expect(last_insight.comments_count).to eq 1
            expect(last_insight.required_reviews_count_ratio).to eq 0
            expect(last_insight.reviews_count_ratio).to eq 0
            expect(last_insight.average_review_seconds_ratio).to eq 0
            expect(last_insight.comments_count_ratio).to eq 0
            # entity2 has 1 open pull request, but this attribute is disabled -> result is 0
            expect(last_insight.open_pull_requests_count).to eq 0
            expect(last_insight.average_merge_seconds).to eq 0
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

            pr_entity1 = create :pull_requests_entity, pull_request: old_pr1, entity: entity2
            create_list :pull_requests_comment, 2, pull_requests_entity: pr_entity1

            old_pr3 =
              create :pull_request,
                     repository: repository,
                     pull_created_at: 40.days.ago,
                     pull_merged_at: 35.days.ago,
                     entity: entity1

            pr_entity3 = create :pull_requests_entity, pull_request: old_pr3, entity: entity2
            create :pull_requests_review, pull_requests_entity: pr_entity3, review_created_at: 39.days.ago
          end

          context 'with default insight attributes' do
            it 'creates 1 insight' do
              expect { service_call }.to change(insightable.insights, :count).by(1)
            end

            it 'insight has default list of attributes', :aggregate_failures do
              service_call

              last_insight = Insight.last

              expect(last_insight.required_reviews_count).to eq 1
              expect(last_insight.reviews_count).to eq 1
              expect(last_insight.average_review_seconds).not_to eq 0
              expect(last_insight.comments_count).to eq 1
              expect(last_insight.required_reviews_count_ratio).to eq(-50)
              expect(last_insight.reviews_count_ratio).to eq 0
              expect(last_insight.average_review_seconds_ratio).to eq(-100)
              expect(last_insight.comments_count_ratio).to eq(-50)
              # entity2 has 1 open pull request, but this attribute is disabled -> result is 0
              expect(last_insight.open_pull_requests_count).to eq 0
              expect(last_insight.average_merge_seconds).to eq 0
            end
          end

          context 'with custom insight attributes' do
            before do
              create :pull_requests_comment, pull_requests_entity: pr_entity1
              create :pull_requests_comment, pull_requests_entity: pr_entity1

              pr_entity = create :pull_requests_entity, pull_request: old_pr2, entity: entity1
              create :pull_requests_comment, pull_requests_entity: pr_entity

              repository.company.configuration.insight_fields = {
                comments_count: true,
                reviews_count: true,
                required_reviews_count: true,
                open_pull_requests_count: true,
                average_open_pr_comments: true,
                average_review_seconds: true,
                average_merge_seconds: true
              }
              repository.company.save!
            end

            it 'creates 1 insight' do
              expect { service_call }.to change(insightable.insights, :count).by(1)
            end

            it 'insight has full list of attributes', :aggregate_failures do
              service_call

              last_insight = Insight.last

              expect(last_insight.required_reviews_count).to eq 1
              expect(last_insight.required_reviews_count_ratio).to eq(-50)
              expect(last_insight.reviews_count).to eq 1
              expect(last_insight.reviews_count_ratio).to eq 0
              expect(last_insight.average_review_seconds).not_to eq 0
              expect(last_insight.average_review_seconds_ratio).to eq(-100)
              expect(last_insight.comments_count).to eq 1
              expect(last_insight.comments_count_ratio).to eq(-50)
              expect(last_insight.open_pull_requests_count).to eq 1
              expect(last_insight.open_pull_requests_count_ratio).to eq 0
              expect(last_insight.average_merge_seconds).to eq 10
              expect(last_insight.average_merge_seconds_ratio).to eq(-100)
              expect(last_insight.average_open_pr_comments).to eq 3
              expect(last_insight.average_open_pr_comments_ratio).to eq 200
            end
          end
        end
      end
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end

  context 'for company insightable' do
    let(:insightable) { repository.company }

    context 'for unexisting insights' do
      it 'creates 2 insights' do
        expect { service_call }.to change(insightable.insights, :count).by(2)
      end
    end

    context 'for existing insight' do
      let!(:insight) { create :insight, insightable: insightable, entity: entity1, comments_count: 0 }

      it 'creates 1 insight' do
        expect { service_call }.to change(insightable.insights, :count).by(1)
      end

      it 'updates existing insight' do
        service_call

        expect(insight.reload.comments_count).to eq 1
      end
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end
end
