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

  def event_registry
    Rails.configuration.event_registry
  end

  def given_domain_event(stream_name, domain_event)
    store_event = event_registry.domain_to_store(domain_event)
    event_store.publish(store_event, stream_name: stream_name)
  end

  def then_stored_event(stream_name, event_class, data)
    events = event_store.read.stream(stream_name).of_type(event_class).to_a
    assert_event_with_data(events, event_class, data)
  end

  def then_domain_event(stream_name, domain_event)
    store_event = event_registry.domain_to_store(domain_event)
    domain_events = event_store.read.stream(stream_name).of_type(store_event.class)
                        .map { |stored_event| event_registry.store_to_domain(stored_event) }.to_a

    matching_event = domain_events.find do |event|
      event == domain_event
    end
    assert matching_event, "Expected to find a #{domain_event.class} event with data #{domain_event.to_h}, but none was found."
  end

  def then_stored_events_count(stream_name, event_class, expected_count)
    actual_count = event_store.read.stream(stream_name).of_type(event_class).to_a.size
    assert_equal expected_count, actual_count, "Expected #{expected_count} #{event_class} events in stream #{stream_name}, but found #{actual_count}."
  end

  private

  def assert_event_with_data(stream_stored_events, stored_event, data)
    matching_event = stream_stored_events.find do |event|
      event_data = event.data.deep_symbolize_keys
      data.all? { |key, value| event_data[key] == value }
    end
    assert matching_event, "Expected to find a #{stored_event} event with data #{data}, but none was found."
  end
end
