# frozen_string_literal: true

shared_examples_for 'required api auth' do
  context 'for unlogged users' do
    it 'returns unauthorized response' do
      do_request

      expect(response).to have_http_status :unauthorized
    end
  end
end
