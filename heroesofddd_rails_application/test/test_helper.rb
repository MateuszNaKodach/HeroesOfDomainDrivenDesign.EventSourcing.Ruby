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

  def publish_event(stream_name, domain_event)
    store_event = event_mapper.domain_to_store(domain_event)
    event_store.publish(store_event, stream_name: stream_name)
  end

  def assert_event_present(event_class, data)
    events = event_store.read.of_type(event_class).to_a
    assert_event_matches(events, event_class, data)
  end

  def assert_event_stream_contains(stream_name, event_class, data)
    events = event_store.read.stream(stream_name).of_type(event_class).to_a
    assert_event_matches(events, event_class, data)
  end

  def assert_event_count(event_class, expected_count)
    actual_count = event_store.read.of_type(event_class).to_a.size
    assert_equal expected_count, actual_count, "Expected #{expected_count} #{event_class} events, but found #{actual_count}."
  end

  def assert_event_matches(events, event_class, data)
    matching_event = events.find do |event|
      data.all? { |key, value| event.data[key] == value }
    end
    assert matching_event, "Expected to find a #{event_class} event with data #{data}, but none was found."
  end

  def assert_event_count_in_stream(stream_name, event_class, expected_count)
    actual_count = event_store.read.stream(stream_name).of_type(event_class).to_a.size
    assert_equal expected_count, actual_count, "Expected #{expected_count} #{event_class} events in stream #{stream_name}, but found #{actual_count}."
  end
end
