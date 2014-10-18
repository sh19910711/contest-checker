lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

ENV['RACK_ENV']                              = 'test'
ENV['CHECK_CF_CONTEST_HATENA_USER_ID']       = "user"
ENV['CHECK_CF_CONTEST_HATENA_USER_PASSWORD'] = "password"
ENV['CHECK_CF_CONTEST_HATENA_GROUP_ID']      = "group"
ENV['CHECK_CF_CONTEST_SECRET_URL']           = "test_url"
ENV['CHECK_CF_CONTEST_SECRET_TOKEN']         = "test"

# coding: utf-8
require 'simplecov'
require 'simplecov-rcov'
require 'rubygems'
require 'spork'
require 'byebug'

def read_file_from_mock(path)
  File.read(File.dirname(__FILE__) + path)
end

Spork.prefork do
  require 'rack/test'
  require 'webmock/rspec'
  # WebMock.allow_net_connect!

  RSpec.configure do |config|
    config.include Rack::Test::Methods

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.filter_run :focus

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = 'random'
  end

  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end

Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  if ENV['DRB']
    require 'simplecov'
  end
end


