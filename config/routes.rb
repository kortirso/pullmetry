# frozen_string_literal: true

require 'que/web'

Rails.application.routes.draw do
  mount PgHero::Engine, at: 'pghero'
  mount Emailbutler::Engine => '/emailbutler'
  mount Que::Web => '/que'

  get 'auth/:provider/callback', to: 'users/omniauth_callbacks#create'
  get 'logout', to: 'users/omniauth_callbacks#destroy'

  namespace :api do
    namespace :v1 do
      resources :companies, only: %i[] do
        resources :insights, only: %i[index]
      end
      resources :repositories, only: %i[] do
        resources :insights, only: %i[index]
        resources :repository_insights, only: %i[index], module: 'repositories'
      end
    end
  end

  resources :companies, except: %i[show edit update] do
    resource :configuration, only: %i[edit update], module: 'companies'
    resources :repositories, only: %i[index new], module: 'companies'
    resources :access_tokens, only: %i[new create]
  end
  resources :repositories, only: %i[index new create destroy] do
    resources :access_tokens, only: %i[new create]
  end

  resource :profile, only: %i[show update destroy]
  resource :achievements, only: %i[show]
  resources :vacations, only: %i[new create destroy]

  post 'subscriptions/trial', to: 'subscriptions/trial#create'

  get 'privacy', to: 'welcome#privacy'
  get 'sources', to: 'welcome#sources'
  get 'how-it-works', to: 'welcome#how_it_works'

  root 'welcome#index'
end
