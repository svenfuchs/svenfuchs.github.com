require File.expand_path('../lib/bundler/repository', __FILE__)

source :rubygems

workspace '~/.projects ~/projects ~/Development/{projects,work}'
adva_cms = repository('adva-cms2', :source => :local)

adva_cms.gem  'adva-blog'
adva_cms.gem  'adva-core'
adva_cms.gem  'adva-static'

gem 'rails', '3.0.0'

group :test do
  gem 'sqlite3-ruby', '1.2.5'
  gem 'cucumber', '0.9.0'
  gem 'cucumber-rails', '0.3.2'
  gem 'webrat', '0.7.0' # '0.7.2.beta.1'
  gem 'thor'
  gem 'ruby-debug'
  gem 'mocha'
  gem 'fakefs', :require => 'fakefs/safe'
  gem 'test_declarative'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'factory_girl', '1.3.2'
end
