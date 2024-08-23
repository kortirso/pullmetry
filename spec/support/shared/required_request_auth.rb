# frozen_string_literal: true

shared_examples_for 'required request auth' do
  context 'for unlogged users' do
    it 'redirects to login page', :aggregate_failures do
      do_request

      expect(response).to redirect_to root_path
      follow_redirect!

      expect(response.body).to include('Get the PR statistics you always needed')
    end
  end
end
