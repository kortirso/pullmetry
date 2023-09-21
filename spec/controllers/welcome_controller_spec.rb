# frozen_string_literal: true

describe WelcomeController do
  describe 'GET#index' do
    it 'renders index template' do
      get :index, params: { locale: 'en' }

      expect(response).to render_template :index
    end
  end

  describe 'GET#privacy' do
    it 'renders privacy template' do
      get :privacy, params: { locale: 'en' }

      expect(response).to render_template :privacy
    end
  end

  describe 'GET#sources' do
    it 'renders sources template' do
      get :sources, params: { locale: 'en' }

      expect(response).to render_template :sources
    end
  end

  describe 'GET#how_it_works' do
    it 'renders how_it_works template' do
      get :how_it_works, params: { locale: 'en' }

      expect(response).to render_template :how_it_works
    end
  end
end
