# frozen_string_literal: true

describe Import::SyncRepositoriesJob, type: :service do
  subject(:job_call) { described_class.perform_now(id: company.id) }

  let!(:company) { create :company }
  let(:import_object) { double }

  before do
    allow(Import::CompanyService).to receive(:new).and_return(import_object)
    allow(import_object).to receive(:call)
  end

  context 'without working time' do
    it 'calls service' do
      job_call

      expect(import_object).to have_received(:call).with(company: company)
    end
  end

  context 'with working time' do
    before do
      company.configuration.assign_attributes(
        work_start_time: DateTime.new(2023, 1, 1, 9, 0),
        work_end_time: DateTime.new(2023, 1, 1, 18, 0),
        work_time_zone: 'Moscow'
      )
      company.save!
    end

    context 'with current time inside working time' do
      before do
        allow(DateTime).to receive(:now).and_return(DateTime.new(2023, 1, 2, 10, 0))
      end

      it 'calls service' do
        job_call

        expect(import_object).to have_received(:call).with(company: company)
      end
    end

    context 'with current time inside working time with timezone offset' do
      before do
        allow(DateTime).to receive(:now).and_return(DateTime.new(2023, 1, 2, 8, 0))
      end

      it 'calls service' do
        job_call

        expect(import_object).to have_received(:call).with(company: company)
      end
    end

    context 'with current time at weekend' do
      before do
        allow(DateTime).to receive(:now).and_return(DateTime.new(2023, 1, 1, 10, 0))
      end

      it 'does not call service' do
        job_call

        expect(import_object).not_to have_received(:call)
      end
    end

    context 'with current time outside working time' do
      before do
        allow(DateTime).to receive(:now).and_return(DateTime.new(2023, 1, 2, 5, 0))
      end

      it 'does not call service' do
        job_call

        expect(import_object).not_to have_received(:call)
      end
    end
  end
end
