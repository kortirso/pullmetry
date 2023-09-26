# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Js and css
gem 'jsbundling-rails', '~> 1.0'
gem 'sprockets-rails'
gem 'tailwindcss-rails'

# A framework for building view components
gem 'view_component', '~> 3.0', require: 'view_component/engine'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1'

# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard
gem 'jwt', '~> 2.5'

# dry-rb system
gem 'dry-auto_inject', '~> 1.0'
gem 'dry-container', '~> 0.11.0'
gem 'dry-validation', '~> 1.10'

# Catch unsafe migrations in development
gem 'strong_migrations', '~> 1.4'

# Pretty print
gem 'awesome_print'

# running application
gem 'foreman'

# A performance dashboard for Postgres
gem 'pghero'

# http client
gem 'faraday', '~> 2.0'

# performance metrics
gem 'skylight'

# bugs tracking
gem 'bugsnag'

# background jobs
gem 'que', '~> 2.2.0'
gem 'que-web'
gem 'whenever', require: false

# authorization
gem 'action_policy'

# Work with JSON-backed attributes
gem 'store_model'

# cache store
gem 'redis', '~> 5.0'
gem 'redis-rails'

# achievements system
gem 'kudos'

# event store
gem 'rails_event_store'

# view pagination
gem 'pagy', '~> 6.0'

# database comments
gem 'commento'

# email tracking system
gem 'emailbutler'

# api serializer
gem 'jsonapi-serializer', '2.2.0'

group :development, :test do
  gem 'bullet', git: 'https://github.com/flyerhzm/bullet', branch: 'main'
  gem 'rubocop', '~> 1.35', require: false
  gem 'rubocop-performance', '~> 1.14', require: false
  gem 'rubocop-rails', '~> 2.15', require: false
  gem 'rubocop-rspec', '~> 2.12', require: false
end

group :development do
  # security checks
  gem 'brakeman'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem 'rack-mini-profiler', '>= 2.3.3'

  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano3-puma', github: 'seuros/capistrano-puma'
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', '~> 1.6', require: false
  gem 'capistrano-rvm', require: false
  gem 'sshkit-sudo'

  # email previews
  gem 'letter_opener'
end

group :test do
  gem 'database_cleaner', '~> 2.0'
  gem 'factory_bot_rails', '6.2.0'
  gem 'json_spec', '1.1.5'
  gem 'rails-controller-testing', '1.0.5'
  gem 'rspec-rails', '~> 6.0'
  gem 'ruby_event_store-rspec'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end
