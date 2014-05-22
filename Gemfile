source 'https://rubygems.org'

ruby '2.1.2'

gem 'rails', '4.1.1'

### runtime / server
gem 'therubyracer',  platforms: :ruby

gem 'pg'

gem 'unicorn'

### view
gem 'sass-rails', '~> 4.0.3'
gem 'yui-compressor'

gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'uglifier', '>= 1.3.0'
gem 'haml-rails'

gem 'compass-rails'
gem 'foundation-rails'
gem 'zurui-sass-rails'

gem 'nokogiri'

### utility
gem 'devise'
gem 'bcrypt', '~> 3.1.7'

gem 'newrelic_rpm'
gem 'foreman'
gem 'figaro'
gem 'mina'

gem 'rb-readline'

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :development do
  gem 'erb2haml'

  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'quiet_assets'

  gem 'pry-rails'
  gem 'pry-coolline'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'pry-doc'

  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'hirb'
  gem 'hirb-unicode'
  gem 'awesome_print'

  gem 'rubocop'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rake_shared_context'
  gem 'fuubar'

  gem 'factory_girl_rails'

  gem 'database_rewinder'

  gem 'guard-rspec'
  gem 'guard-spring'
end

group :production do
  gem 'rails_12factor'
end