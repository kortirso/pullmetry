# frozen_string_literal: true

describe Insights::AverageTime::ForMergeService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:repository) { create :repository }
  let!(:pr1) { create :pull_request, repository: repository, pull_created_at: DateTime.new(2023, 1, 3, 12, 0, 0) }
  let!(:pr2) {
    create :pull_request,
           repository: repository,
           pull_created_at: DateTime.new(2023, 1, 2, 12, 0, 0),
           pull_merged_at: DateTime.new(2023, 1, 3, 13, 0, 0)
  }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }
  let!(:entity3) { create :entity, external_id: '3' }

  before do
    create :pull_requests_entity, pull_request: pr1, entity: entity1
    create :pull_requests_entity, pull_request: pr2, entity: entity2
    create :pull_requests_entity, pull_request: pr2, entity: entity3, origin: PullRequests::Entity::REVIEWER
  end

  context 'for repository insightable' do
    let(:insightable) { repository }

    it 'generates average time' do
      expect(service_call.result).to eq({ entity2.id => 90_000 })
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end

    context 'when some PR does not have pull_created_at' do
      before { pr2.update!(pull_created_at: nil) }

      it 'generates average time without such PRs' do
        expect(service_call.result).to eq({})
      end

      it 'succeeds' do
        expect(service_call.success?).to be_truthy
      end
    end

    context 'when some PR has pull_created_at after reviewed' do
      before { pr2.update!(pull_created_at: DateTime.new(2023, 1, 4, 1, 0, 0)) }

      it 'generates less average time for such PRs' do
        expect(service_call.result).to eq({ entity2.id => 1 })
      end

      it 'succeeds' do
        expect(service_call.success?).to be_truthy
      end
    end
  end

  context 'for company insightable' do
    let(:insightable) { repository.company }

    it 'generates average time' do
      expect(service_call.result).to eq({ entity2.id => 90_000 })
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
        expect(service_call.result).to eq({ entity2.id => 32_400 })
      end

      it 'succeeds' do
        expect(service_call.success?).to be_truthy
      end
    end

    context 'for company insightable' do
      let(:insightable) { repository.company }

      it 'generates average time' do
        expect(service_call.result).to eq({ entity2.id => 32_400 })
      end

      it 'succeeds' do
        expect(service_call.success?).to be_truthy
      end
    end

    context 'with more than 1 day between dates' do
      before { pr2.update!(pull_merged_at: DateTime.new(2023, 1, 4, 10, 0, 0)) }

      context 'for repository insightable' do
        let(:insightable) { repository }

        it 'generates average time' do
          expect(service_call.result).to eq({ entity2.id => 50_400 })
        end

        it 'succeeds' do
          expect(service_call.success?).to be_truthy
        end
      end

      context 'for company insightable' do
        let(:insightable) { repository.company }

        it 'generates average time' do
          expect(service_call.result).to eq({ entity2.id => 50_400 })
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
            expect(service_call.result).to eq({ entity2.id => 50_400 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity2.id => 50_400 })
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
            expect(service_call.result).to eq({ entity2.id => 79_200 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity2.id => 79_200 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end
      end

      context 'with PR created and merged at weekend' do
        before do
          pr2.update!(
            pull_created_at: DateTime.new(2022, 12, 30, 12, 0, 0),
            pull_merged_at: DateTime.new(2023, 1, 1, 12, 0, 0)
          )
        end

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity2.id => 0 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time' do
            expect(service_call.result).to eq({ entity2.id => 0 })
          end

          it 'succeeds' do
            expect(service_call.success?).to be_truthy
          end
        end
      end
    end
  end
end
