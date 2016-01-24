source 'https://rubygems.org'

ruby '2.2.4'

group :production, :development do
  gem 'mechanize', :require => false
  gem 'nokogiri', :require => false
  gem 'sinatra', :require => false
  gem 'google-api-client', '~> 0.8.6', :require => false
  gem 'activesupport', :require => false
  gem 'simple-rss', :require => false
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

