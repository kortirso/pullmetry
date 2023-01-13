# frozen_string_literal: true

describe RobotsController do
  describe 'GET#index' do
    it 'renders index template' do
      get :index

      expect(response).to render_template 'robots/index'
    end
  end
end
