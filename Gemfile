source 'https://rubygems.org'

ruby '2.1.4'

group :production, :development do
  gem 'mechanize'
  gem 'nokogiri'
  gem 'sinatra'
  gem 'google-api-client'
end

group :development do
  gem 'shotgun'
  gem 'byebug'
end

group :test do
  gem 'rake'
  gem 'rspec'
  gem 'rack-test', require: 'rack/test'
  gem 'webmock'

  gem 'spork'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'ci_reporter'
end

