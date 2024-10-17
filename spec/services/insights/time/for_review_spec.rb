# frozen_string_literal: true

describe Insights::Time::ForReview, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable, pull_requests_ids: pull_requests_ids) }

  let!(:first_monday) {
    date = DateTime.now.beginning_of_month + 7.days
    date -= 1.day until date.wday == 1
    DateTime.new(date.year, date.month, date.day)
  }
  let!(:repository) { create :repository }
  let!(:pr1) { create :pull_request, repository: repository, pull_created_at: first_monday + 1.day + 12.hours }
  let!(:pr2) { create :pull_request, repository: repository, pull_created_at: first_monday + 12.hours }
  let!(:entity1) { create :entity, external_id: '1' }
  let!(:entity2) { create :entity, external_id: '2' }
  let!(:prr1) {
    create :pull_request_review, pull_request: pr1, entity: entity1, review_created_at: first_monday + 2.days
  }
  let!(:prr3) {
    create :pull_request_review, pull_request: pr2, entity: entity2, review_created_at: first_monday + 13.hours
  }
  let(:pull_requests_ids) { [pr1.id, pr2.id] }

  before do
    create :pull_request_review, pull_request: pr1, entity: entity1, review_created_at: first_monday + 1.day + 14.hours
  end

  context 'for repository insightable' do
    let(:insightable) { repository }

    it 'generates average time and succeeds', :aggregate_failures do
      expect(service_call[:result]).to eq({ entity1.id => [43_200, 7_200], entity2.id => [3_600] })
      expect(service_call[:errors]).to be_blank
    end

    context 'when some PR does not have pull_created_at' do
      before { pr1.update!(pull_created_at: nil) }

      it 'generates average time without such PRs and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity2.id => [3_600] })
        expect(service_call[:errors]).to be_blank
      end
    end

    context 'when some PR has pull_created_at after reviewed' do
      before { pr1.update!(pull_created_at: first_monday + 2.days + 1.hour) }

      it 'generates less average time for such PRs and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity1.id => [1, 1], entity2.id => [3_600] })
        expect(service_call[:errors]).to be_blank
      end
    end
  end

  context 'for company insightable' do
    let(:insightable) { repository.company }

    it 'generates average time and succeeds', :aggregate_failures do
      expect(service_call[:result]).to eq({ entity1.id => [43_200, 7_200], entity2.id => [3_600] })
      expect(service_call[:errors]).to be_blank
    end
  end

  context 'for company with working time' do
    before { create :work_time, starts_at: '09:00', ends_at: '17:00', worktimeable: repository.company }

    context 'for repository insightable' do
      let(:insightable) { repository }

      it 'generates average time and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity1.id => [18_000, 7_200], entity2.id => [3_600] })
        expect(service_call[:errors]).to be_blank
      end
    end

    context 'for company insightable' do
      let(:insightable) { repository.company }

      it 'generates average time and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity1.id => [18_000, 7_200], entity2.id => [3_600] })
        expect(service_call[:errors]).to be_blank
      end
    end

    context 'with more than 1 day between dates' do
      before { prr1.update!(review_created_at: first_monday + 3.days + 10.hours) }

      context 'for repository insightable' do
        let(:insightable) { repository }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity1.id => [50_400, 7_200], entity2.id => [3_600] })
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'for company insightable' do
        let(:insightable) { repository.company }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity1.id => [50_400, 7_200], entity2.id => [3_600] })
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'with PR created at weekend' do
        before { pr2.update!(pull_created_at: first_monday - 12.hours) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity1.id => [50_400, 7_200], entity2.id => [14_400] })
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity1.id => [50_400, 7_200], entity2.id => [14_400] })
            expect(service_call[:errors]).to be_blank
          end
        end
      end

      context 'with PR created before weekend' do
        before { pr2.update!(pull_created_at: first_monday - 2.days - 12.hours) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity1.id => [50_400, 7_200], entity2.id => [32_400] })
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity1.id => [50_400, 7_200], entity2.id => [32_400] })
            expect(service_call[:errors]).to be_blank
          end
        end
      end

      context 'with PR created and reviewed at weekend' do
        before do
          pr2.update!(pull_created_at: first_monday - 1.day - 12.hours)
          prr3.update!(review_created_at: first_monday - 11.hours)
        end

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity1.id => [50_400, 7_200], entity2.id => [0] })
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity1.id => [50_400, 7_200], entity2.id => [0] })
            expect(service_call[:errors]).to be_blank
          end
        end
      end
    end
  end
end
