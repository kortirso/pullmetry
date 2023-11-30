# frozen_string_literal: true

shared_examples_for 'required frontend auth' do
  context 'for unlogged users' do
    it 'redirects to login page' do
      do_request

      expect(response).to have_http_status :unauthorized
    end
  end
end
