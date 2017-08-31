#
# Change to match your CPU core count
workers 2

# Min and Max threads per worker
threads 1, 6

app_dir = File.expand_path("../../", __FILE__)
tmp_dir = "#{app_dir}/tmp"

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

# Set up socket location
if rails_env == 'production'
	bind "tcp://127.0.0.1:9292"
end

# Logging
stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{tmp_dir}/tmp/pids/puma.pid"
state_path "#{tmp_dir}/tmp/pids/puma.state"

activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
