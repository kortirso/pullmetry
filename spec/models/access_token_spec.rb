# frozen_string_literal: true

describe AccessToken do
  it 'factory should be valid' do
    access_token = build :access_token

    expect(access_token).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:tokenable) }
  end

  describe '#expired?' do
    let!(:access_token) { create :access_token, expired_at: nil }

    it 'returns false' do
      expect(access_token.expired?).to be_falsy
    end

    context 'with not expired value' do
      before { access_token.update!(expired_at: 1.day.after) }

      it 'returns false' do
        expect(access_token.expired?).to be_falsy
      end
    end

    context 'with expired value' do
      before { access_token.update!(expired_at: 1.day.ago) }

      it 'returns true' do
        expect(access_token.expired?).to be_truthy
      end
    end
  end
end
