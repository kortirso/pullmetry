# frozen_string_literal: true

describe Companies::Configurations::UpdateForm, type: :service do
  subject(:form) { instance.call(company: company, params: params, use_work_time: use_work_time) }

  let!(:instance) { described_class.new }
  let!(:company) { create :company }
  let(:use_work_time) { false }

  context 'with different fetch_period' do
    context 'for nil fetch_period' do
      let(:params) { { fetch_period: nil } }

      it 'sets nil for fetch_period', :aggregate_failures do
        expect(form.errors).to be_blank
        expect(company.reload.configuration.fetch_period).to be_nil
      end
    end

    context 'for small period' do
      let(:params) { { fetch_period: Insight::FETCH_DAYS_PERIOD } }

      it 'sets value for fetch_period', :aggregate_failures do
        expect(form.errors).to be_blank
        expect(company.reload.configuration.fetch_period).to eq Insight::FETCH_DAYS_PERIOD
      end
    end

    context 'for big period' do
      let(:params) { { fetch_period: Insight::MAXIMUM_FETCH_DAYS_PERIOD } }

      it 'does not set value for fetch_period', :aggregate_failures do
        expect(form.errors).not_to be_blank
        expect(company.reload.configuration.fetch_period).to be_nil
      end

      context 'for premium account' do
        before { create :subscription, user: company.user }

        it 'sets value for fetch_period', :aggregate_failures do
          expect(form.errors).to be_blank
          expect(company.reload.configuration.fetch_period).to eq Insight::MAXIMUM_FETCH_DAYS_PERIOD
        end

        context 'for huge period' do
          let(:params) { { fetch_period: Insight::MAXIMUM_FETCH_DAYS_PERIOD + 1 } }

          it 'does not set value for fetch_period', :aggregate_failures do
            expect(form.errors).not_to be_blank
            expect(company.reload.configuration.fetch_period).to be_nil
          end
        end
      end
    end
  end
end
