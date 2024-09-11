# frozen_string_literal: true

describe AddFeedbackCommand do
  subject(:command) { instance.call(params.merge(user: user)) }

  let!(:instance) { described_class.new }
  let!(:user) { create :user }

  context 'for invalid params' do
    let(:params) { { description: '', email: 'email@gmail.com' } }

    it 'does not create feedback', :aggregate_failures do
      expect { command }.not_to change(Feedback, :count)
      expect(command[:errors]).not_to be_blank
    end
  end

  context 'for valid params' do
    let(:params) { { description: 'description', email: 'email@gmail.com' } }

    it 'creates feedback', :aggregate_failures do
      expect { command }.to change(user.feedbacks, :count).by(1)
      expect(Feedback.last.email).to be_nil
      expect(command[:errors]).to be_nil
    end

    context 'when answerable is true' do
      let(:params) { { description: 'description', answerable: true, email: 'email@gmail.com' } }

      it 'creates feedback', :aggregate_failures do
        expect { command }.to change(user.feedbacks, :count).by(1)
        expect(Feedback.last.email).to eq 'email@gmail.com'
        expect(command[:errors]).to be_nil
      end
    end
  end
end
