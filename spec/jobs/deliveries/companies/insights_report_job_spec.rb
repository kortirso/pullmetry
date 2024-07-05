# frozen_string_literal: true

describe Deliveries::Companies::InsightsReportJob, type: :service do
  subject(:job_call) { described_class.perform_now }

  let!(:user) { create :user }
  let!(:company) { create :company, user: user }
  let!(:webhook) { create :webhook, company: company }
  let(:delivery_service) { double }
  let(:date) {
    value = DateTime.now
    value = value.change(day: value.day + (2 * (value < 29 ? 1 : -1))) if value.wday.in?([0, 6])
    value
  }

  before do
    allow(CompanyDelivery).to receive(:with).and_return(delivery_service)
    allow(delivery_service).to receive(:insights_report).and_return(delivery_service)
    allow(delivery_service).to receive(:deliver_later)
  end

  context 'without notifications' do
    it 'does not calls service' do
      job_call

      expect(CompanyDelivery).not_to have_received(:with)
    end
  end

  context 'with notifications' do
    before do
      create :notification, notifyable: company, webhook: webhook, notification_type: Notification::INSIGHTS_DATA
    end

    context 'without working time' do
      it 'calls service' do
        job_call

        expect(CompanyDelivery).to have_received(:with).with(company: company)
      end
    end

    context 'with working time' do
      before do
        company.configuration.assign_attributes(
          work_start_time: DateTime.new(date.year, date.month, date.day, 9, 0),
          work_end_time: DateTime.new(date.year, date.month, date.day, 18, 0),
          work_time_zone: 'UTC'
        )
        company.save!
      end

      context 'with current time inside working time' do
        before do
          allow(DateTime).to receive(:now).and_return(DateTime.new(date.year, date.month, date.day, 10, 0))

          create :subscription, user: user, start_time: date - 10.days, end_time: date + 10.days
        end

        it 'calls service' do
          job_call

          expect(CompanyDelivery).to have_received(:with).with(company: company)
        end
      end

      context 'with current time outside working time' do
        before do
          allow(DateTime).to receive(:now).and_return(DateTime.new(date.year, date.month, date.day, 7, 0))
        end

        it 'does not call service' do
          job_call

          expect(CompanyDelivery).not_to have_received(:with)
        end
      end
    end
  end
end
