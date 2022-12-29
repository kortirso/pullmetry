# frozen_string_literal: true

shared_examples_for 'required email confirmation' do
  context 'for unconfirmed users' do
    sign_in_unconfirmed_user

    it 'render shared error' do
      do_request

      expect(response).to redirect_to users_confirm_en_path
    end
  end
end
