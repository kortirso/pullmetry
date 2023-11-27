# frozen_string_literal: true

describe Ignores::CreateForm, type: :service do
  subject(:form) { instance.call(company: company, params: params) }

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
      expect { form }.not_to change(Ignore, :count)
      expect(form[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { entity_value: 'octocat[bot]' } }

    it 'creates ignore', :aggregate_failures do
      expect { form }.to(
        change(company.ignores, :count).by(1)
          .and(change(company.insights, :count).by(-1))
          .and(change(repository.insights, :count).by(-1))
      )
      expect(form[:result].is_a?(Ignore)).to be_truthy
    end
  end
end
