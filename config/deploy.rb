require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

set :user, 'refxgroovin'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'refxgroovin'
set :repository, 'git@github.com:mayth/refixative.git'
set :branch, 'next'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, [
  'config/database.yml',
  'config/unicorn.rb',
  'config/application.yml',
  'log'
]

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  case ENV['to']
  when 'staging'
    set :deploy_to, "/home/#{user}/refixative-staging"
  when 'production'
    set :deploy_to, "/home/#{user}/refixative"
  when nil
    fail 'specify `to`, deployment target'
  else
    fail 'unknown deployment target'
  end

  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  invoke :'rbenv:load'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/pids"]

  shared_configs = %w(database.yml unicorn.rb application.yml)
  shared_configs.each do |conf|
    queue! %[touch "#{deploy_to}/shared/config/#{conf}"]
  end
  queue  %[echo "-----> Be sure to edit the following files in 'shared/config':"]
  shared_configs.each do |conf|
    queue  %[echo "----->   * #{conf}"]
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      env = ENV['to'] == 'production' ? '' : ".#{ENV['to']}"
      cmd = ENV['reload'] || 'reload'
      queue %[sudo /etc/init.d/refxgroovin#{env} #{cmd}]
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

