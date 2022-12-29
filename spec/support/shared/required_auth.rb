# frozen_string_literal: true

shared_examples_for 'required auth' do
  context 'for unlogged users' do
    it 'redirects to login page' do
      do_request

      expect(response).to redirect_to users_login_en_path
    end
  end
end
