ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end


module EventStoreTest
  def event_store
    Rails.configuration.event_store
  end

  def command_bus
    Rails.configuration.command_bus
  end

  def event_mapper
    Rails.configuration.event_mapper
  end

  def store_event(domain_event)
    event_mapper.domain_to_store(domain_event)
  end

  def store_event_class(domain_event_class)
    event_mapper.domain_to_store_class(domain_event_class)
  end
end
