# frozen_string_literal: true

describe AddRepositoryCommand do
  subject(:command) { instance.call(params.merge(company: company)) }

  let!(:instance) { described_class.new }
  let!(:company) { create :company }

  context 'for invalid params' do
    let(:params) { { title: '', link: '' } }

    it 'does not create repository and fails', :aggregate_failures do
      expect { command }.not_to change(Repository, :count)
      expect(command[:errors]).not_to be_empty
    end
  end

  context 'for invalid external id' do
    let(:params) { { title: 'Title', link: 'https://gitlab.com', provider: 'gitlab' } }

    it 'does not create repository and fails', :aggregate_failures do
      expect { command }.not_to change(Repository, :count)
      expect(command[:errors]).not_to be_empty
    end
  end

  context 'for invalid link' do
    let(:params) { { title: 'Title', link: 'https://gitlab.com', provider: 'github' } }

    it 'does not create repository and fails', :aggregate_failures do
      expect { command }.not_to change(Repository, :count)
      expect(command[:errors]).not_to be_empty
    end
  end

  context 'for invalid git link' do
    let(:params) { { title: 'Title', link: 'https://gitlab.com.git', provider: 'github' } }

    it 'does not create repository and fails', :aggregate_failures do
      expect { command }.not_to change(Repository, :count)
      expect(command[:errors]).not_to be_empty
    end
  end

  context 'for valid external id' do
    let(:params) { { title: 'Title', link: 'https://gitlab.com', provider: 'gitlab', external_id: '1' } }

    it 'creates repository and succeeds', :aggregate_failures do
      expect { command }.to change(company.repositories, :count).by(1)
      expect(command[:errors]).to be_blank
    end
  end

  context 'for valid params' do
    let!(:repository) { create :repository, link: 'https://github.com' }
    let(:params) { { title: 'Title', link: 'https://github.com', provider: 'github' } }

    it 'creates repository and destroys old repository', :aggregate_failures do
      command

      expect(Repository.find_by(id: repository.id)).to be_nil
      expect(company.repositories.count).to eq 1
    end

    context 'when user has access to repository with the same link' do
      before { repository.update!(company: company) }

      it 'does not create repository and fails' do
        expect { command }.not_to change(Repository, :count)
      end
    end

    context 'when there is repository with the same link' do
      let!(:insight) { create :insight, insightable: repository }

      it 'does not create repository and fails' do
        expect { command }.not_to change(Repository, :count)
      end

      context 'when insight is old' do
        before do
          insight.updated_at = 13.hours.ago
          insight.save(touch: false)
        end

        it 'creates repository and destroys old repository', :aggregate_failures do
          command

          expect(Repository.find_by(id: repository.id)).to be_nil
          expect(company.repositories.count).to eq 1
        end
      end
    end
  end
end
