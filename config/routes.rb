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
    resources :repositories, only: %i[index destroy]
    resources :configurations, only: %i[index]
    resources :notifications, only: %i[index]
    resources :webhooks, only: %i[index]
    resources :feedbacks, only: %i[index]
    resources :users, only: %i[index]
  end

  namespace :api do
    namespace :frontend do
      resources :companies, only: %i[create] do
        resources :insights, only: %i[index]
      end
      resources :repositories, only: %i[create] do
        resources :insights, only: %i[index]
        resources :repository_insights, only: %i[index], module: 'repositories'
      end
      resources :notifications, only: %i[create destroy]
      resources :ignores, only: %i[create]
      resources :invites, only: %i[create]
      resource :feedback, only: %i[create]
      resources :ignores, only: %i[destroy]
      resources :webhooks, only: %i[create destroy]
      resources :vacations, only: %i[create destroy]
      namespace :excludes do
        resources :groups, only: %i[create destroy]
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
  resources :subscribers, only: %i[create]
  namespace :subscribers do
    resource :unsubscribe, only: %i[show]
  end

  post 'subscriptions/trial', to: 'subscriptions/trial#create'

  get 'privacy', to: 'welcome#privacy'
  get 'metrics', to: 'welcome#metrics'

  root 'welcome#index'
end
