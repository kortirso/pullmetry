# frozen_string_literal: true

describe Insights::AverageTime::ForMergeService, type: :service do
  subject(:service_call) { described_class.call(insightable: insightable) }

  let!(:identity) { create :identity }
  let!(:first_monday) {
    date = DateTime.now.beginning_of_month
    date -= 1.day until date.wday == 1
    DateTime.new(date.year, date.month, date.day)
  }
  let!(:repository) { create :repository }
  let!(:pr2) {
    create :pull_request,
           repository: repository,
           pull_created_at: first_monday + 12.hours,
           pull_merged_at: first_monday + 1.day + 13.hours,
           entity: entity2
  }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2', identity: identity }
  let!(:entity3) { create :entity, external_id: '3' }

  before do
    create :pull_request,
           repository: repository,
           pull_created_at: first_monday + 1.day + 12.hours,
           entity: entity1

    create :pull_requests_entity, pull_request: pr2, entity: entity3
  end

  context 'for repository insightable' do
    let(:insightable) { repository }

    it 'generates average time and succeeds', :aggregate_failures do
      expect(service_call.result).to eq({ entity2.id => 90_000 })
      expect(service_call.success?).to be_truthy
    end

    context 'when some PR does not have pull_created_at' do
      before { pr2.update!(pull_created_at: nil) }

      it 'generates average time without such PRs and succeeds', :aggregate_failures do
        expect(service_call.result).to eq({})
        expect(service_call.success?).to be_truthy
      end
    end

    context 'when some PR has pull_created_at after reviewed' do
      before { pr2.update!(pull_created_at: first_monday + 2.days + 1.hour) }

      it 'generates less average time for such PRs and succeeds', :aggregate_failures do
        expect(service_call.result).to eq({ entity2.id => 1 })
        expect(service_call.success?).to be_truthy
      end
    end
  end

  context 'for company insightable' do
    let(:insightable) { repository.company }

    it 'generates average time and succeeds', :aggregate_failures do
      expect(service_call.result).to eq({ entity2.id => 90_000 })
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

      it 'generates average time and succeeds', :aggregate_failures do
        expect(service_call.result).to eq({ entity2.id => 32_400 })
        expect(service_call.success?).to be_truthy
      end

      context 'for user with work time' do
        before do
          identity.user.update!(
            work_start_time: DateTime.new(2023, 1, 1, 9, 0, 0),
            work_end_time: DateTime.new(2023, 1, 1, 16, 0, 0)
          )
        end

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call.result).to eq({ entity2.id => 28_800 })
          expect(service_call.success?).to be_truthy
        end
      end
    end

    context 'for company insightable' do
      let(:insightable) { repository.company }

      it 'generates average time and succeeds', :aggregate_failures do
        expect(service_call.result).to eq({ entity2.id => 32_400 })
        expect(service_call.success?).to be_truthy
      end
    end

    context 'with more than 1 day between dates' do
      before { pr2.update!(pull_merged_at: first_monday + 2.days + 10.hours) }

      context 'for repository insightable' do
        let(:insightable) { repository }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call.result).to eq({ entity2.id => 50_400 })
          expect(service_call.success?).to be_truthy
        end
      end

      context 'for company insightable' do
        let(:insightable) { repository.company }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call.result).to eq({ entity2.id => 50_400 })
          expect(service_call.success?).to be_truthy
        end
      end

      context 'with PR created at weekend' do
        before { pr2.update!(pull_created_at: first_monday - 12.hours) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call.result).to eq({ entity2.id => 61_200 })
            expect(service_call.success?).to be_truthy
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call.result).to eq({ entity2.id => 61_200 })
            expect(service_call.success?).to be_truthy
          end
        end
      end

      context 'with PR created before weekend' do
        before { pr2.update!(pull_created_at: first_monday - 2.days - 12.hours) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call.result).to eq({ entity2.id => 79_200 })
            expect(service_call.success?).to be_truthy
          end

          context 'with vacation for author' do
            before { create :vacation, user: identity.user, start_time: first_monday, end_time: first_monday + 2.days }

            it 'generates average time and succeeds', :aggregate_failures do
              expect(service_call.result).to eq({ entity2.id => 18_000 })
              expect(service_call.success?).to be_truthy
            end
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call.result).to eq({ entity2.id => 79_200 })
            expect(service_call.success?).to be_truthy
          end
        end
      end

      context 'with PR created and merged at weekend' do
        before do
          pr2.update!(
            pull_created_at: first_monday - 2.days + 12.hours,
            pull_merged_at: first_monday - 12.hours
          )
        end

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call.result).to eq({ entity2.id => 0 })
            expect(service_call.success?).to be_truthy
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call.result).to eq({ entity2.id => 0 })
            expect(service_call.success?).to be_truthy
          end
        end
      end
    end
  end
end
