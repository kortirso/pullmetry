# frozen_string_literal: true

describe Repositories::CreateForm, type: :service do
  subject(:form) { instance.call(company: company, params: params) }

  let!(:instance) { described_class.new }
  let!(:company) { create :company }

  context 'for invalid params' do
    let(:params) { { title: '', link: '' } }

    it 'does not create repository and fails' do
      expect { form }.not_to change(Repository, :count)
    end
  end

  context 'for invalid external id' do
    let(:params) { { title: 'Title', link: 'link', provider: 'gitlab' } }

    it 'does not create repository and fails' do
      expect { form }.not_to change(Repository, :count)
    end
  end

  context 'for valid external id' do
    let(:params) { { title: 'Title', link: 'link', provider: 'gitlab', external_id: '1' } }

    it 'creates repository and succeeds' do
      expect { form }.to change(company.repositories, :count).by(1)
    end
  end

  context 'for valid params' do
    let!(:repository) { create :repository, link: 'link' }
    let(:params) { { title: 'Title', link: 'link', provider: 'github' } }

    it 'creates repository and destroys old repository', :aggregate_failures do
      form

      expect(Repository.find_by(id: repository.id)).to be_nil
      expect(company.repositories.count).to eq 1
    end

    context 'when user has access to repository with the same link' do
      before { repository.update!(company: company) }

      it 'does not create repository and fails' do
        expect { form }.not_to change(Repository, :count)
      end
    end

    context 'when there is repository with the same link' do
      let!(:insight) { create :insight, insightable: repository }

      it 'does not create repository and fails' do
        expect { form }.not_to change(Repository, :count)
      end

      context 'when insight is old' do
        before do
          insight.updated_at = 13.hours.ago
          insight.save(touch: false)
        end

        it 'creates repository and destroys old repository', :aggregate_failures do
          form

          expect(Repository.find_by(id: repository.id)).to be_nil
          expect(company.repositories.count).to eq 1
        end
      end
    end
  end
end
