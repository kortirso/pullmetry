# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.17.1'

set :application, 'pullmetry'
set :repo_url, 'git@github.com:kortirso/pullmetry.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/html/pullmetry'
set :deploy_user, 'deploy'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/log', 'public/system', 'vendor'

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 2

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# set :sitemap_roles, :web # default

# puma settings
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/tmp/log/puma.access.log"
set :puma_error_log, "#{shared_path}/tmp/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true # Change to false when not using ActiveRecord

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  after :publishing, :restart
end

namespace :yarn do
  desc 'Yarn'
  task :install do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec yarn install'
        end
      end
    end
  end
end

namespace :que do
  desc 'Start que worker'
  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec que -l error ./config/environment.rb'
        end
      end
    end
  end

  desc 'Stop que worker'
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute "ps aux | grep '[b]in/que' | awk '{ print $2 }' | xargs kill"
        end
      end
    end
  end
end

after 'bundler:install', 'yarn:install'
after 'deploy:published', 'bundler:clean'

# after server restart need to do
# cap production que:start

# after deploy need to do
# cap production que:stop
# cap production que:start
