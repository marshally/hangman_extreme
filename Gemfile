source 'https://rubygems.org'

gem 'rails', '4.0.0.beta1'

platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', :require => false
end
platforms :ruby do
  gem 'pg'
end
gem 'ohm'
gem 'ohm-contrib', :require => 'ohm/contrib'

platforms :jruby do
  gem 'jruby-openssl'
end
gem 'cancan'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'kaminari'
gem 'mxit_api', '>= 0.2.2.pre'
gem "savon"
gem 'draper'
gem 'puma'
gem 'whenever', :require => false

gem 'sidekiq'
# todo favor Strong Parameters
gem 'protected_attributes'

gem 'sinatra', '>= 1.3.0', :require => nil # for sidekiq
gem 'slim', :require => nil # for sidekiq

#gem 'backup', :require => false
#gem 'httparty', :require => false # for backup
#gem 'dropbox-sdk', :require => false  # for backup

# third party
gem 'airbrake'
gem 'uservoice-ruby'
gem 'gabba' # google analytics
gem 'newrelic_rpm'
gem 'wordnik'
gem 'librato-metrics', :require => 'librato/metrics'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  platforms :jruby do
    gem 'therubyrhino'
  end
  platforms :ruby do
    gem 'libv8', '~> 3.11.8'
    gem 'therubyracer'
  end
  # gem 'sass-rails',   '~> 4.0.0.beta1'
  # gem 'coffee-rails', '~> 4.0.0.beta1'
  gem 'uglifier', '>= 1.0.3'
  gem "jquery-rails"
end

group :development do
  gem 'capistrano', :require => false
  gem 'rvm-capistrano', :require => false
end

group :development, :test do
  gem 'timecop'
  gem 'annotate'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  platforms :jruby do
    gem 'jdbc-mysql'
    gem 'activerecord-jdbcmysql-adapter', :require => false
  end
  platforms :ruby do
    gem 'mysql2'
  end
  platforms :jruby do
    gem 'activerecord-jdbcsqlite3-adapter', :require => false
    gem 'activerecord-jdbcpostgresql-adapter', :require => false
  end
  platforms :ruby do
    gem 'sqlite3'
    gem 'pg'
  end
  gem 'shoulda-matchers'
  gem 'test_after_commit'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'capybara', '~> 2.0.0'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'flog'
  # gem "spork-rails"
  gem 'webmock'
  gem 'vcr'
  gem 'coveralls', require: false
end
