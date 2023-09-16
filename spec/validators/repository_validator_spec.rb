# frozen_string_literal: true

describe RepositoryValidator, type: :service do
  subject(:validator_call) { described_class.new.call(params: params) }

  context 'for invalid format' do
    let(:params) { { title: 'title', link: 'link', provider: '' } }

    it 'result contains error' do
      expect(validator_call.first).to eq('Provider must be filled')
    end
  end

  context 'for valid params' do
    let(:params) { { title: 'title', link: 'link', provider: 'provider' } }

    it 'result does not contain errors' do
      expect(validator_call.empty?).to be_truthy
    end
  end

  context 'for gitlab' do
    context 'for invalid format' do
      let(:params) { { title: 'title', link: 'link', provider: 'gitlab', external_id: '' } }

      it 'result contains error' do
        expect(validator_call.first).to eq("External id can't be blank")
      end
    end

    context 'for valid params' do
      let(:params) { { title: 'title', link: 'link', provider: 'gitlab', external_id: 'external_id' } }

      it 'result does not contain errors' do
        expect(validator_call.empty?).to be_truthy
      end
    end
  end
end
