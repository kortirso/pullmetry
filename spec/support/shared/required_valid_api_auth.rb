# frozen_string_literal: true

shared_examples_for 'required valid api auth' do
  context 'for invalid api token' do
    it 'returns unauthorized response' do
      do_request('invalid_token')

      expect(response).to have_http_status :unauthorized
    end
  end
end
