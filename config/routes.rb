# frozen_string_literal: true

require 'que/view'

Rails.application.routes.draw do
  mount PgHero::Engine, at: 'pghero'
  mount Emailbutler::Engine => '/emailbutler'
  mount Que::View::Engine => '/que_view'

  get 'auth/:provider/callback', to: 'users/omniauth_callbacks#create'
  get 'logout', to: 'users/omniauth_callbacks#destroy'

  namespace :admin do
    get '', to: 'welcome#index'

    resources :companies, only: %i[index] do
      resources :repositories, only: %i[index], module: 'companies'
    end
    resources :repositories, only: %i[index]
    resources :configurations, only: %i[index]
    resources :feedbacks, only: %i[index]
  end

  namespace :api do
    namespace :frontend do
      resources :companies, only: %i[create] do
        resources :insights, only: %i[index]
        resources :ignores, only: %i[create]
        resources :webhooks, only: %i[create]
        resource :notifications, only: %i[create destroy]
        namespace :excludes do
          resources :groups, only: %i[create]
        end
        resources :invites, only: %i[create]
      end
      resources :repositories, only: %i[create] do
        resources :insights, only: %i[index]
        resources :repository_insights, only: %i[index], module: 'repositories'
      end
      resource :feedback, only: %i[create]
      resources :ignores, only: %i[destroy]
      resources :webhooks, only: %i[destroy]
      resources :vacations, only: %i[create destroy]
      namespace :excludes do
        resources :groups, only: %i[destroy]
      end
      resources :invites, only: %i[destroy]
    end
  end

  namespace :webhooks do
    resource :telegram, only: %i[create]
    resource :cryptocloud, only: %i[create]
  end

  namespace :confirmations do
    get 'cryptocloud-success', to: 'cryptocloud#success'
    get 'cryptocloud-failure', to: 'cryptocloud#failure'
  end

  resources :companies, only: %i[index destroy] do
    resource :configuration, only: %i[edit update], module: 'companies'
    resources :repositories, only: %i[index], module: 'companies'
    resources :access_tokens, only: %i[new create]
  end
  resources :repositories, only: %i[index destroy] do
    resources :access_tokens, only: %i[new create]
  end

  resource :profile, only: %i[show update destroy]
  resource :achievements, only: %i[show]
  resources :identities, only: %i[destroy]

  post 'subscriptions/trial', to: 'subscriptions/trial#create'

  get 'privacy', to: 'welcome#privacy'
  get 'sources', to: 'welcome#sources'
  get 'how-it-works', to: 'welcome#how_it_works'
  get 'metrics', to: 'welcome#metrics'

  root 'welcome#index'
end
