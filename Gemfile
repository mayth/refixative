source 'https://rubygems.org'

# Distribute your app as a gem
# gemspec

# Server requirements
gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'sass'
gem 'haml'
gem 'activerecord', '>= 3.1', :require => 'active_record'
gem 'sqlite3'
group :production do
  gem 'pg'
end
gem 'nokogiri'

# Test requirements
gem 'mocha', :group => 'test', :require => false
gem 'rspec', :group => 'test'
gem 'rack-test', :require => 'rack/test', :group => 'test'

# Padrino Stable Gem
gem 'padrino', '0.11.4'

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.11.4'
# end
