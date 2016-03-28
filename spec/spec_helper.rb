require 'bundler/setup'
Bundler.setup

require 'rspec/collection_matchers'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'rails'
require 'rails_newsfeed'
require 'models/user_feed'

require 'coveralls'
Coveralls.wear!

require 'factory_girl'
require 'faker'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include FactoryGirl::Syntax::Methods
  config.before(:suite) do
    FactoryGirl.find_definitions
  end
end
