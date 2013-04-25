require 'rubygems'
# require 'spork'

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

#Spork.prefork do
#  ENV["RAILS_ENV"] ||= 'test'

  if ENV['HEADLESS']
    require 'headless'
  end

  if (ENV['COVERAGE'] == 'on')
    require 'simplecov'
    require 'simplecov-rcov'
    class SimpleCov::Formatter::MergedFormatter
      def format(result)
        SimpleCov::Formatter::HTMLFormatter.new.format(result)
        SimpleCov::Formatter::RcovFormatter.new.format(result)
      end
    end
    SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
    SimpleCov.start 'rails' do
      add_filter "/vendor/"
    end
  end

  #require "rails/application"
  ## Prevent main application to eager_load in the prefork block (do not load files in autoload_paths)
  #Spork.trap_method(Rails::Application, :eager_load!)
  #Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

#  require 'webmock/rspec'
#  WebMock.allow_net_connect!
  require File.expand_path("../../config/environment", __FILE__)

  # Load all railties files
  #Rails.application.railties.all { |r| r.eager_load! }
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'webmock/rspec'
  require 'draper/test/rspec_integration'
  require 'capybara/rails'
  require 'capybara/rspec'
  require 'capybara/poltergeist'
  require 'sidekiq/testing'
  require 'coveralls'
#end

#Spork.each_run do
  Coveralls.wear!
#  FactoryGirl.find_definitions
  DatabaseCleaner.clean_with :truncation

  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    c.hook_into :webmock
    c.ignore_localhost = true
  end

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, window_size: [320,480] )
    end
    Capybara.javascript_driver = :poltergeist
    Capybara.default_wait_time = 30

    config.filter_run_excluding :redis => true if ENV["EXCLUDE_REDIS_SPECS"]

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      (@@headless = Headless.new).start if ENV['HEADLESS']
    end

    config.after(:suite) do
      @@headless.destroy if ENV['HEADLESS']
    end

    config.before(:all, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end

    config.after(:all, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
      Rails.cache.clear
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.before(:each, :redis => true) do
      Ohm.flush
    end

    config.around(:each, :facebook => true) do |example|
      using_facebook_omniauth(&example)
    end

    config.around(:each, :shinka_vcr => true) do |example|
      VCR.use_cassette('shinka',
                       :record => :once,
                       :erb => true,
                       :allow_playback_repeats => true,
                       :match_requests_on => [:method,:host]) do
        example.call
      end
    end

    config.around(:each, :smaato_vcr => true) do |example|
      VCR.use_cassette('smaato',
                       :record => :once,
                       :erb => true,
                       :allow_playback_repeats => true,
                       :match_requests_on => [:method,:host]) do
        example.call
      end
    end

  end
#
#end