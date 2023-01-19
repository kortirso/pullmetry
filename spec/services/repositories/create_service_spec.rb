# frozen_string_literal: true

describe Repositories::CreateService, type: :service do
  subject(:service_call) { described_class.call(company: company, params: params) }

  let!(:company) { create :company }

  context 'for invalid params' do
    let(:params) { { title: '', link: '' } }

    it 'does not create repository' do
      expect { service_call }.not_to change(Repository, :count)
    end

    it 'fails' do
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for invalid external id' do
    let(:params) { { title: 'Title', link: 'link', provider: 'gitlab' } }

    it 'does not create repository' do
      expect { service_call }.not_to change(Repository, :count)
    end

    it 'fails' do
      expect(service_call.failure?).to be_truthy
    end
  end

  context 'for valid external id' do
    let(:params) { { title: 'Title', link: 'link', provider: 'gitlab', external_id: '1' } }

    it 'creates repository' do
      expect { service_call }.to change(company.repositories, :count).by(1)
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end
  end

  context 'for valid params' do
    let!(:repository) { create :repository, link: 'link' }
    let(:params) { { title: 'Title', link: 'link', provider: 'github' } }

    it 'creates repository' do
      expect { service_call }.to change(company.repositories, :count).by(1)
    end

    it 'succeeds' do
      expect(service_call.success?).to be_truthy
    end

    context 'when user has access to repository with the same link' do
      before { repository.update!(company: company) }

      it 'does not create repository' do
        expect { service_call }.not_to change(Repository, :count)
      end

      it 'fails' do
        expect(service_call.failure?).to be_truthy
      end
    end

    context 'when there is repository with the same link' do
      let!(:insight) { create :insight, insightable: repository }

      it 'does not create repository' do
        expect { service_call }.not_to change(Repository, :count)
      end

      it 'fails' do
        expect(service_call.failure?).to be_truthy
      end

      context 'when insight is old' do
        before do
          insight.updated_at = 13.hours.ago
          insight.save(touch: false)
        end

        it 'creates repository' do
          expect { service_call }.to change(company.repositories, :count).by(1)
        end

        it 'succeeds' do
          expect(service_call.success?).to be_truthy
        end
      end
    end
  end
end
