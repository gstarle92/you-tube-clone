lock "~> 3.14.1"


set :repo_url,       'git@github.com:gstarle92/you-tube-clone.git'

set :user,            'gokul'
set :rvm_type,        :user   # Defaults to: :auto
# set :rvm_custom_path, "/usr/local/rvm"
set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}_puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord


## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{ .env }
set :linked_dirs,  %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public }

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
  
  desc 'Sleep for a few seconds then start puma'
  task :sleepy_start do
    sleep(20)
    invoke 'puma:start'
  end

  before :start, :make_dirs
  after :deploy, "puma:sleepy_start"
end

namespace :rails do
  desc "Run the console on a remote server."
  task :console do
    on roles(:app) do |h|
      execute_interactively "RAILS_ENV=#{fetch(:rails_env)} bundle exec rails console", h.user
    end
  end

  def execute_interactively(command, user)
    info "Connecting with #{user}@#{host}"
    cmd = "ssh amani@#{host} -p 9090 -t 'cd #{fetch(:deploy_to)}/current && #{command}'"
    exec cmd
  end
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:sleepy_start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  # desc 'Create symbolink for uploads' 
  # task :create_uploads_symlink do
  #   on roles(:app) do
  #     execute "cd #{deploy_to}/current/public"
  #     execute "rm -rf uploads"
  #     execute "ln -s /home/mugabo/apps/brazza/shared/public/uploads/"
  #   end
  # end

  desc "Remove Doc Files"  
  task :remove_doc_files do
    on roles(:app) do
      execute "rm -rf #{deploy_to}/current/doc/"
    end
  end

  desc "create symbolic link for puma.rb in config folder, to make the upstart script work"
  task :symlink_puma_config do
    on roles(:app) do
      execute "cd #{release_path}/config && ln -s #{shared_path}/puma.rb"
    end
  end


  before :starting,     :check_revision
  # after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  # after  :finishing,    :restart
  # after  :finishing,    :create_uploads_symlink
  after :finishing, :remove_doc_files
  # after :published, :symlink_puma_config
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma