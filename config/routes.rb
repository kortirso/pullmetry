# frozen_string_literal: true

require 'que/web'

Rails.application.routes.draw do
  mount PgHero::Engine, at: 'pghero'
  mount Que::Web => '/que'

  get 'auth/:provider/callback', to: 'users/omniauth_callbacks#create'
  get 'logout', to: 'users/omniauth_callbacks#destroy'

  resources :companies, except: %i[show edit update] do
    resource :configuration, only: %i[edit update], module: 'companies'
  end
  resources :repositories, only: %i[index new create destroy]
  resources :access_tokens, only: %i[new create]

  get 'privacy', to: 'welcome#privacy'

  root 'welcome#index'
end
