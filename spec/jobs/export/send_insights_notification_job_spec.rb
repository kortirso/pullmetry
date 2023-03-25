# frozen_string_literal: true

describe Export::SendInsightsNotificationJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:user) { create :user }
  let!(:company) { create :company, user: user }
  let(:send_service) { double(Export::Slack::Insights::SendService) }
  let(:date) {
    value = DateTime.now
    value = value.change(day: value.day + 2) if value.wday.in?([0, 6])
    value
  }

  before do
    allow(Export::Slack::Insights::SendService).to receive(:new).and_return(send_service)
    allow(send_service).to receive(:call)
  end

  context 'without active subscription' do
    it 'does not calls service' do
      job_call

      expect(send_service).not_to have_received(:call)
    end
  end

  context 'with active subscription' do
    before { create :subscription, user: user, start_time: 10.days.ago, end_time: 10.days.after }

    context 'without working time' do
      it 'calls service' do
        job_call

        expect(send_service).to have_received(:call).with(insightable: company)
      end
    end

    context 'with working time' do
      before do
        company.configuration.assign_attributes(
          work_start_time: DateTime.new(date.year, date.month, date.day, 9, 0),
          work_end_time: DateTime.new(date.year, date.month, date.day, 18, 0)
        )
        company.save!
      end

      context 'with current time inside working time' do
        before do
          allow(DateTime).to receive(:now).and_return(DateTime.new(date.year, date.month, date.day, 10, 0))
        end

        it 'calls service' do
          job_call

          expect(send_service).to have_received(:call).with(insightable: company)
        end
      end

      context 'with current time outside working time' do
        before do
          allow(DateTime).to receive(:now).and_return(DateTime.new(date.year, date.month, date.day, 7, 0))
        end

        it 'does not call service' do
          job_call

          expect(send_service).not_to have_received(:call)
        end
      end
    end
  end
end
