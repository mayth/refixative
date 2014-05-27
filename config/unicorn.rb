app_root = ENV['RAILS_ROOT'] || File.expand_path('.')

worker_processes Integer(ENV['WEB_CONCURRENCY'] || 4)
timeout 15
preload_app true
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

listen 9382

stderr_path File.join(app_root, 'log', 'unicorn.log')
stdout_path File.join(app_root, 'log', 'unicorn.log')

pid File.join(app_root, 'shared', 'pids', 'unicorn.pid')

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
