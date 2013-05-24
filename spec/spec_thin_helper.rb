require 'rubygems'

ENV["RAILS_ENV"] ||= 'test'
ENV["RACK_ENV"] ||= 'test'

require 'rspec/autorun'

$:<< File.join(File.dirname(__FILE__), '..') # add current directory to load path


RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  config.before(:suite) do

  end

  config.after(:suite) do
  end

  config.before(:each) do
  end

  config.after(:each) do
  end

end