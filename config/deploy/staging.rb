server '165.22.119.35', roles: [:web, :app, :db], primary: true
set :user, 'gokul'
set :application,   'you-toube-clone'
set :deploy_to,  "/home/gokul/you-toube-clone"
set :puma_state, "/home/gokul/you-toube-clone/shared/tmp/pids/puma.state"
set :puma_pid, "/home/gokul/you-toube-clone/shared/tmp/pids/puma.pid"
set :puma_bind, "unix:///home/gokul/you-toube-clone/shared/tmp/sockets/you-toube-clone_puma.sock"