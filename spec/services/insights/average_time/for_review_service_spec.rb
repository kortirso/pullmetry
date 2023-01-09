# frozen_string_literal: true

describe Insights::AverageTime::ForReviewService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:repository) { create :repository }
  let!(:pr1) { create :pull_request, repository: repository, pull_created_at: DateTime.new(2023, 1, 3, 12, 0, 0) }
  let!(:pr2) { create :pull_request, repository: repository, pull_created_at: DateTime.new(2023, 1, 2, 12, 0, 0) }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }
  let!(:pre1) {
    create :pull_requests_entity, pull_request: pr1, entity: entity1, origin: PullRequests::Entity::REVIEWER
  }
  let!(:pre2) {
    create :pull_requests_entity, pull_request: pr2, entity: entity2, origin: PullRequests::Entity::REVIEWER
  }
  let!(:prr1) {
    create :pull_requests_review, pull_requests_entity: pre1, review_created_at: DateTime.new(2023, 1, 4, 0, 0, 0)
  }
  let!(:prr3) {
    create :pull_requests_review, pull_requests_entity: pre2, review_created_at: DateTime.new(2023, 1, 2, 13, 0, 0)
  }

  before do
    create :pull_requests_review, pull_requests_entity: pre1, review_created_at: DateTime.new(2023, 1, 3, 14, 0, 0)
  end

  context 'for repository insightable' do
    let(:insightable) { repository }

    it 'generates average time' do
      expect(service_call.result).to eq({ entity1.id => 25_200, entity2.id => 3_600 })
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end

  context 'for company insightable' do
    let(:insightable) { repository.company }

    it 'generates average time' do
      expect(service_call.result).to eq({ entity1.id => 25_200, entity2.id => 3_600 })
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end

  context 'for company with working time' do
    before do
      repository.company.update!(
        configuration: {
          work_start_time: DateTime.new(2023, 1, 1, 9, 0, 0),
          work_end_time: DateTime.new(2023, 1, 1, 17, 0, 0)
        }
      )
    end

    context 'for repository insightable' do
      let(:insightable) { repository }

      it 'generates average time' do
        expect(service_call.result).to eq({ entity1.id => 12_600, entity2.id => 3_600 })
      end

      it 'succeeds' do
        expect(service_call.success?).to be_truthy
      end
    end

    context 'for company insightable' do
      let(:insightable) { repository.company }

      it 'generates average time' do
        expect(service_call.result).to eq({ entity1.id => 12_600, entity2.id => 3_600 })
      end

      it 'succeeds' do
        expect(service_call.success?).to be_truthy
      end
    end

    context 'with more than 1 day between dates' do
      before { prr1.update!(review_created_at: DateTime.new(2023, 1, 5, 10, 0, 0)) }

      context 'for repository insightable' do
        let(:insightable) { repository }

        it 'generates average time' do
          expect(service_call.result).to eq({ entity1.id => 28_800, entity2.id => 3_600 })
        end

        it 'succeeds' do
          expect(service_call.success?).to be_truthy
        end
      end

      context 'for company insightable' do
        let(:insightable) { repository.company }

        it 'generates average time' do
          expect(service_call.result).to eq({ entity1.id => 28_800, entity2.id => 3_600 })
        end

        it 'succeeds' do
          expect(service_call.success?).to be_truthy
        end
      end

      context 'with PR created at weekend' do
        before { pr2.update!(pull_created_at: DateTime.new(2023, 1, 1, 12, 0, 0)) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity1.id => 28_800, entity2.id => 3_600 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity1.id => 28_800, entity2.id => 3_600 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end
      end

      context 'with PR created before weekend' do
        before { pr2.update!(pull_created_at: DateTime.new(2022, 12, 30, 12, 0, 0)) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity1.id => 28_800, entity2.id => 32_400 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity1.id => 28_800, entity2.id => 32_400 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end
      end

      context 'with PR created and reviewed at weekend' do
        before do
          pr2.update!(pull_created_at: DateTime.new(2022, 12, 31, 12, 0, 0))
          prr3.update!(review_created_at: DateTime.new(2023, 1, 1, 13, 0, 0))
        end

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity1.id => 28_800, entity2.id => 0 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity1.id => 28_800, entity2.id => 0 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end
      end
    end
  end
end