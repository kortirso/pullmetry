# frozen_string_literal: true

describe ChangeCompanyConfigurationCommand do
  subject(:service_call) { instance.call({ company: company }.merge(params)) }

  let!(:instance) { described_class.new }
  let!(:company) { create :company }

  context 'for regular account' do
    context 'for insight_fields' do
      let(:params) { { insight_fields: ['comments_count'] } }

      it 'does not update configuration', :aggregate_failures do
        service_call

        expect(company.reload.current_config.selected_insight_fields).to match_array(Insight::DEFAULT_ATTRIBUTES.map(&:to_s))
      end
    end

    context 'for fetch period' do
      let(:params) { { fetch_period: fetch_period } }

      context 'for invalid value' do
        let(:fetch_period) { 31 }

        it 'does not update configuration', :aggregate_failures do
          service_call

          expect(company.reload.current_config.fetch_period).to eq 30
          expect(service_call[:errors]).to eq(['Fetch period too long'])
        end
      end

      context 'for valid value' do
        let(:fetch_period) { 15 }

        it 'updates configuration' do
          service_call

          expect(company.reload.current_config.fetch_period).to eq 15
        end
      end
    end
  end

  context 'for premium account' do
    before { create :user_subscription, user: company.user }

    context 'for insight_fields' do
      let(:params) { { insight_fields: ['comments_count'] } }

      it 'sets only specific insight_fields as enabled', :aggregate_failures do
        service_call

        expect(company.reload.current_config.selected_insight_fields).to contain_exactly('comments_count')
      end
    end

    context 'for fetch period' do
      let(:params) { { fetch_period: fetch_period } }

      context 'for invalid value' do
        let(:fetch_period) { 91 }

        it 'does not update configuration', :aggregate_failures do
          service_call

          expect(company.reload.current_config.fetch_period).to eq 30
          expect(service_call[:errors]).to eq(['Fetch period must be less than or equal to 90'])
        end
      end

      context 'for valid big value' do
        let(:fetch_period) { 45 }

        it 'updates configuration' do
          service_call

          expect(company.reload.current_config.fetch_period).to eq 45
        end
      end

      context 'for valid value' do
        let(:fetch_period) { 15 }

        it 'updates configuration' do
          service_call

          expect(company.reload.current_config.fetch_period).to eq 15
        end
      end
    end
  end
end
