# frozen_string_literal: true

require 'que/view'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount PgHero::Engine, at: 'pghero'
  mount Emailbutler::Engine => '/emailbutler'
  mount Que::View::Engine => '/que_view'
  mount Authkeeper::Engine => '/authkeeper'

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
    resources :subscribers, only: %i[index]
  end

  namespace :api do
    namespace :v1 do
      resources :companies, only: %i[index]
      resources :companies, only: %i[] do
        resources :insights, only: %i[index]
      end
      resources :repositories, only: %i[] do
        resources :insights, only: %i[index]
      end
    end
  end

  namespace :frontend do
    resources :work_times, only: %i[create]
    resources :companies, only: %i[create] do
      resource :configuration, only: %i[update], module: 'companies'
      resource :transfer, only: %i[create], module: 'companies'
      resources :insights, only: %i[index]
      resources :access_tokens, only: %i[create]
    end
    resources :repositories, only: %i[create] do
      resources :insights, only: %i[index]
      resources :repository_insights, only: %i[index], module: 'repositories'
      resources :access_tokens, only: %i[create]
    end
    resources :notifications, only: %i[create destroy]
    resources :invites, only: %i[create]
    resources :webhooks, only: %i[create destroy]
    namespace :excludes do
      resources :groups, only: %i[create destroy]
    end
    namespace :companies do
      resources :users, only: %i[destroy]
    end
    resources :invites, only: %i[destroy]
    resources :api_access_tokens, only: %i[create destroy]
    namespace :users do
      resources :vacations, only: %i[create destroy]
      resource :feedback, only: %i[create]
    end
    namespace :entities do
      resources :ignores, only: %i[create destroy]
    end
  end

  namespace :webhooks do
    resource :telegram, only: %i[create]
    resource :cryptocloud, only: %i[create]
  end

  scope module: :web do
    get 'auth/:provider/callback', to: 'users/omniauth_callbacks#create'
    get 'logout', to: 'users/omniauth_callbacks#destroy'

    namespace :confirmations do
      get 'cryptocloud-success', to: 'cryptocloud#success'
      get 'cryptocloud-failure', to: 'cryptocloud#failure'
    end

    resources :companies, only: %i[index destroy] do
      resource :configuration, only: %i[edit], module: 'companies'
      resources :repositories, only: %i[index], module: 'companies'
    end
    resources :repositories, only: %i[index destroy]

    resource :profile, only: %i[show destroy]
    resource :achievements, only: %i[show]
    resources :identities, only: %i[destroy]
    resources :subscribers, only: %i[create]
    namespace :subscribers do
      resource :unsubscribe, only: %i[show]
    end

    get 'subscriptions/trial', to: 'subscriptions/trial#create'

    get 'privacy', to: 'welcome#privacy'
    get 'metrics', to: 'welcome#metrics'
    get 'access_tokens', to: 'welcome#access_tokens'
  end

  get '/500', to: 'web/errors#internal'
  get 'forbidden', to: 'web/errors#forbidden'

  root 'web/welcome#index'
end
