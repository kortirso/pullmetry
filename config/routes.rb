# frozen_string_literal: true

require 'que/web'

Rails.application.routes.draw do
  mount PgHero::Engine, at: 'pghero'
  mount Emailbutler::Engine => '/emailbutler'
  mount Que::Web => '/que'

  get 'auth/:provider/callback', to: 'users/omniauth_callbacks#create'
  get 'logout', to: 'users/omniauth_callbacks#destroy'

  resources :companies, except: %i[show edit update] do
    resource :configuration, only: %i[edit update], module: 'companies'
  end
  resources :repositories, only: %i[index new create destroy]
  resources :access_tokens, only: %i[new create]
  resource :profile, only: %i[show update destroy]
  resource :achievements, only: %i[show]
  resources :vacations, only: %i[new create destroy]

  post 'subscriptions/trial', to: 'subscriptions/trial#create'

  get 'privacy', to: 'welcome#privacy'
  get 'sources', to: 'welcome#sources'

  get 'sitemap.xml', to: 'sitemaps#index', format: :xml
  get 'robots.txt', to: 'robots#index'

  root 'welcome#index'
end
