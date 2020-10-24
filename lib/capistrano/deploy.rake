namespace :deploy do

    desc 'Restart ActionCable'
    task :restart_action_cable do
      on roles(:app), in: :sequence, wait: 5 do
        instances = JSON.parse(capture(:'passenger-config', 'list-instances', '--json'))
        instance_name = instances.find { |i| i['integration_mode'] == 'standalone' }&.dig('name')
  
        if instance_name.nil?
          # the server isn't running, put your code to start it here or throw an error
        else
          execute(:'passenger-config', 'restart-app', current_path, '--instance', instance_name)
        end
      end
    end
  
    after :publishing, :restart_action_cable
  
  end