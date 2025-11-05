$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'pry'
require 'active_graph'
require 'graphiti'
require 'graphiti-activegraph'
require_relative 'active_graph/support/jsonapi_resource_support'
require 'support/neo4j_db_cleaner'
require 'support/factory_bot_setup'
require 'support/neo4j_driver_setup'
require 'parslet'

set_default_driver

require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.output_directory = 'coverage'
  c.lcov_file_name = 'lcov.info'
end
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include FactoryBot::Syntax::Methods

  config.before(:suite, neo4j: true) do
    FactoryBot.find_definitions
  end

  config.before(:suite, neo4j: true) do
    Neo4jDbCleaner.start
  ensure
    Neo4jDbCleaner.clean
  end

  config.after(:suite, neo4j: true) do
    ActiveGraph::Base.driver.close
  end

  config.append_after(:example, neo4j: true) do |example|
    unless example.metadata[:skip_deletion]
      Neo4jDbCleaner.clean
      FFaker::UniqueUtils.clear # To avoid FFaker::UniqueUtils::RetryLimitExceeded
    end
  end
end
