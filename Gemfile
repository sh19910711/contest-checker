source 'https://rubygems.org'

ruby "2.2.0"

group :production, :development do
  gem 'mechanize', :require => false
  gem 'nokogiri', :require => false
  gem 'sinatra', :require => false
  gem 'google-api-client', :require => false
  gem 'activesupport', :require => false
end

group :development do
  gem 'shotgun', :require => false
  gem 'byebug', :require => false
end

group :test do
  gem 'rake', :require => false
  gem 'rspec', :require => false
  gem 'rack-test', require: 'rack/test'
  gem 'webmock', :require => false
  gem 'codeclimate-test-reporter', :require => false
end

group :debug do
  gem 'pry', :require => false
  gem 'pry-byebug', :require => false
end

