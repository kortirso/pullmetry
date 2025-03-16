# frozen_string_literal: true

shared_examples_for 'required admin auth' do
  context 'for confirmed users' do
    sign_in_user

    it 'render shared error' do
      do_request

      expect(response).to render_template 'web/errors/forbidden'
    end
  end
end
