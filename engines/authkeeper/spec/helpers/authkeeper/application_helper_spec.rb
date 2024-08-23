# frozen_string_literal: true

describe Authkeeper::ApplicationHelper do
  describe '#omniauth_link' do
    context 'for unexisting provider' do
      it 'returns nil' do
        expect(helper.omniauth_link(:unknown)).to be_nil
      end
    end

    context 'for github provider' do
      it 'returns github link' do
        expect(helper.omniauth_link(:github).include?('https://github.com')).to be_truthy
      end
    end

    context 'for gitlab provider' do
      it 'returns gitlab link' do
        expect(helper.omniauth_link(:gitlab).include?('https://gitlab.com')).to be_truthy
      end
    end
  end
end
