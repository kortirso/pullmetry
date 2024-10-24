# frozen_string_literal: true

describe AddEntityIgnoreCommand, type: :service do
  subject(:command) { instance.call(params.merge(insightable: company)) }

  let!(:instance) { described_class.new }
  let!(:company) { create :company }
  let!(:repository) { create :repository, company: company }
  let!(:entity) { create :entity, login: 'octocat[bot]' }

  before do
    create :insight, insightable: company, entity: entity
    create :insight, insightable: repository, entity: entity

    create :insight, insightable: company
    create :insight, insightable: repository
  end

  context 'for invalid params' do
    let(:params) { { entity_value: '' } }

    it 'does not create ignore', :aggregate_failures do
      expect { command }.not_to change(Entity::Ignore, :count)
      expect(command[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { entity_value: 'octocat[bot]' } }

    it 'creates ignore', :aggregate_failures do
      expect { command }.to(
        change(company.entity_ignores, :count).by(1)
          .and(change(company.insights, :count).by(-1))
          .and(change(repository.insights, :count).by(-1))
      )
      expect(command[:result].is_a?(Entity::Ignore)).to be_truthy
    end

    context 'with existing ignore' do
      before { create :ignore, insightable: company, entity_value: 'octocat[bot]' }

      it 'does not create ignore', :aggregate_failures do
        expect { command }.not_to change(Entity::Ignore, :count)
        expect(command[:errors]).not_to be_blank
      end
    end
  end
end
