# frozen_string_literal: true

describe Insights::Time::ForMerge, type: :service do
  subject(:service_call) { described_class.new.call(insightable: insightable, pull_requests_ids: pull_requests_ids) }

  let!(:identity) { create :identity }
  let!(:first_monday) {
    date = DateTime.now.beginning_of_month + 7.days
    date -= 1.day until date.wday == 1
    DateTime.new(date.year, date.month, date.day)
  }
  let!(:repository) { create :repository }
  let!(:pr1) {
    create :pull_request,
           repository: repository,
           pull_created_at: first_monday + 1.day + 12.hours,
           entity: entity1
  }
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
  let(:pull_requests_ids) { [pr1.id, pr2.id] }

  before do
    create :pull_request_review, pull_request: pr2, entity: entity3
  end

  context 'for repository insightable' do
    let(:insightable) { repository }

    it 'generates average time and succeeds', :aggregate_failures do
      expect(service_call[:result]).to eq({ entity2.id => [90_000] })
      expect(service_call[:errors]).to be_blank
    end

    context 'when some PR does not have pull_created_at' do
      before { pr2.update!(pull_created_at: nil) }

      it 'generates average time without such PRs and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({})
        expect(service_call[:errors]).to be_blank
      end
    end

    context 'when some PR has pull_created_at after reviewed' do
      before { pr2.update!(pull_created_at: first_monday + 2.days + 1.hour) }

      it 'generates less average time for such PRs and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity2.id => [1] })
        expect(service_call[:errors]).to be_blank
      end
    end
  end

  context 'for company insightable' do
    let(:insightable) { repository.company }

    it 'generates average time and succeeds', :aggregate_failures do
      expect(service_call[:result]).to eq({ entity2.id => [90_000] })
      expect(service_call[:errors]).to be_blank
    end
  end

  context 'for company with working time' do
    before { create :work_time, starts_at: '09:00', ends_at: '17:00', worktimeable: repository.company }

    context 'for repository insightable' do
      let(:insightable) { repository }

      it 'generates average time and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity2.id => [32_400] })
        expect(service_call[:errors]).to be_blank
      end

      context 'when company work time zone is not UTC' do
        before { repository.company.work_time.update(timezone: '1') }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity2.id => [32_400] }) # 9 work hours
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'for user with work time' do
        before { create :work_time, starts_at: '09:00', ends_at: '16:00', worktimeable: identity.user }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity2.id => [28_800] }) # 8 work hours
          expect(service_call[:errors]).to be_blank
        end

        context 'when user work time zone is not UTC' do
          before { identity.user.work_time.update!(timezone: '9') }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [25_200] }) # 7 work hours
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'when company ignores user work time' do
          before do
            repository.company.config.assign_attributes(
              ignore_users_work_time: true
            )
            repository.company.save!
          end

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [32_400] }) # 9 work hours
            expect(service_call[:errors]).to be_blank
          end
        end
      end
    end

    context 'for company insightable' do
      let(:insightable) { repository.company }

      it 'generates average time and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity2.id => [32_400] })
        expect(service_call[:errors]).to be_blank
      end
    end

    context 'with more than 1 day between dates' do
      before { pr2.update!(pull_merged_at: first_monday + 2.days + 10.hours) }

      context 'for repository insightable' do
        let(:insightable) { repository }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity2.id => [50_400] })
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'for company insightable' do
        let(:insightable) { repository.company }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity2.id => [50_400] })
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'with PR created at weekend' do
        before { pr2.update!(pull_created_at: first_monday - 12.hours) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [61_200] })
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [61_200] })
            expect(service_call[:errors]).to be_blank
          end
        end
      end

      context 'with PR created before weekend' do
        before { pr2.update!(pull_created_at: first_monday - 2.days - 12.hours) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [79_200] })
            expect(service_call[:errors]).to be_blank
          end

          context 'with vacation for author' do
            before { create :user_vacation, user: identity.user, start_time: first_monday, end_time: first_monday + 2.days }

            it 'generates average time and succeeds', :aggregate_failures do
              expect(service_call[:result]).to eq({ entity2.id => [18_000] })
              expect(service_call[:errors]).to be_blank
            end
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [79_200] })
            expect(service_call[:errors]).to be_blank
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
            expect(service_call[:result]).to eq({ entity2.id => [0] })
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [0] })
            expect(service_call[:errors]).to be_blank
          end
        end
      end
    end
  end

  # PR created at 12 and merged at 13
  context 'for company with night working time' do
    before { create :work_time, starts_at: '20:00', ends_at: '04:00', worktimeable: repository.company }

    context 'for repository insightable' do
      let(:insightable) { repository }

      it 'generates average time and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity2.id => [28_800] })
        expect(service_call[:errors]).to be_blank
      end

      context 'when company work time zone is not UTC' do
        before { repository.company.work_time.update(timezone: '1') }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity2.id => [28_800] }) # 8 work hours
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'for user with work time' do
        before { create :work_time, starts_at: '21:00', ends_at: '04:00', worktimeable: identity.user }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity2.id => [25_200] }) # 7 work hours
          expect(service_call[:errors]).to be_blank
        end

        context 'when user work time zone is not UTC' do
          before { identity.user.work_time.update(timezone: '9') }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [28_800] }) # 8 work hours
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'when company ignores user work time' do
          before do
            repository.company.config.assign_attributes(
              ignore_users_work_time: true
            )
            repository.company.save!
          end

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [28_800] }) # 8 work hours
            expect(service_call[:errors]).to be_blank
          end
        end
      end
    end

    context 'for company insightable' do
      let(:insightable) { repository.company }

      it 'generates average time and succeeds', :aggregate_failures do
        expect(service_call[:result]).to eq({ entity2.id => [28_800] })
        expect(service_call[:errors]).to be_blank
      end
    end

    # PR created at 12 and merged at 10
    context 'with more than 1 day between dates' do
      before { pr2.update!(pull_merged_at: first_monday + 2.days + 10.hours) }

      context 'for repository insightable' do
        let(:insightable) { repository }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity2.id => [57_600] })
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'for company insightable' do
        let(:insightable) { repository.company }

        it 'generates average time and succeeds', :aggregate_failures do
          expect(service_call[:result]).to eq({ entity2.id => [57_600] })
          expect(service_call[:errors]).to be_blank
        end
      end

      context 'with PR created at weekend' do
        before { pr2.update!(pull_created_at: first_monday - 12.hours) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [57_600] })
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [57_600] })
            expect(service_call[:errors]).to be_blank
          end
        end
      end

      context 'with PR created before weekend' do
        before { pr2.update!(pull_created_at: first_monday - 2.days - 12.hours) }

        context 'for repository insightable' do
          let(:insightable) { repository }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [86_400] })
            expect(service_call[:errors]).to be_blank
          end

          context 'with vacation for author' do
            before { create :user_vacation, user: identity.user, start_time: first_monday, end_time: first_monday + 2.days }

            it 'generates average time and succeeds', :aggregate_failures do
              expect(service_call[:result]).to eq({ entity2.id => [28_800] })
              expect(service_call[:errors]).to be_blank
            end
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [86_400] })
            expect(service_call[:errors]).to be_blank
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
            expect(service_call[:result]).to eq({ entity2.id => [0] })
            expect(service_call[:errors]).to be_blank
          end
        end

        context 'for company insightable' do
          let(:insightable) { repository.company }

          it 'generates average time and succeeds', :aggregate_failures do
            expect(service_call[:result]).to eq({ entity2.id => [0] })
            expect(service_call[:errors]).to be_blank
          end
        end
      end
    end
  end
end
