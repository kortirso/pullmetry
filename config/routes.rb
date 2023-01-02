# frozen_string_literal: true

require 'que/web'

Rails.application.routes.draw do
  mount PgHero::Engine, at: 'pghero'
  mount Que::Web => '/que'

  get 'auth/:provider/callback', to: 'users/omniauth_callbacks#create'
  get 'logout', to: 'users/omniauth_callbacks#destroy'

  resources :companies, only: %i[index new create destroy]
  resources :repositories, only: %i[index new create destroy]
  resources :access_tokens, only: %i[new create]
  root 'welcome#index'
end
