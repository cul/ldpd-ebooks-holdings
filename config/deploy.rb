# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

# Until we retire all old CentOS VMs, we need to set the rvm_custom_path because rvm is installed
# in a non-standard location for our AlmaLinux VMs.  This is because our service accounts need to
# maintain two rvm installations for two different Linux OS versions.
set :rvm_custom_path, '~/.rvm-alma8'

set :remote_user, "renserv"
set :application, "ebooks"
set :repo_url, 'git@github.com:cul/ldpd-ebooks-holdings.git'
set :deploy_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :rvm_ruby_version, fetch(:deploy_name)

set :deploy_to,   "/opt/passenger/#{fetch(:deploy_name)}"

# Default value for :linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('tmp/pids', 'db', 'public/static-feeds')

set :passenger_restart_with_touch, true

# Default value for keep_releases is 5
set :keep_releases, 3

# RVM Setup, for selecting the correct ruby version (instead of capistrano-rvm gem)
set :rvm_ruby_version, fetch(:deploy_name) # This RVM alias must exist on the server
[:rake, :gem, :bundle, :ruby].each do |command_to_prefix|
  SSHKit.config.command_map.prefix[command_to_prefix].push(
    "#{fetch(:rvm_custom_path, '~/.rvm')}/bin/rvm #{fetch(:rvm_ruby_version)} do"
  )
end
