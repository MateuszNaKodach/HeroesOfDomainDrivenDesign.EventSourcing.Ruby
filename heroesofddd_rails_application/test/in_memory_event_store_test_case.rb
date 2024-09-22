require "test_helper"

class InMemoryEventStoreTestCase < ActiveSupport::TestCase
  include EventStoreTest

  def before_setup
    result = super
    @previous_event_store = Rails.configuration.event_store
    @previous_command_bus = Rails.configuration.command_bus
    @previous_query_bus = Rails.configuration.query_bus
    @previous_event_registry = Rails.configuration.event_registry
    Rails.configuration.event_store = RubyEventStore::Client.new(
      repository: RubyEventStore::InMemoryRepository.new
    )
    Rails.configuration.command_bus = Arkency::CommandBus.new
    Rails.configuration.query_bus = Arkency::CommandBus.new

    Configuration.new.call(
      Rails.configuration.event_store,
      Rails.configuration.command_bus,
      Rails.configuration.query_bus,
      Rails.configuration.event_registry
    )
    result
  end

  def before_teardown
    result = super
    Rails.configuration.event_store = @previous_event_store
    Rails.configuration.command_bus = @previous_command_bus
    Rails.configuration.query_bus = @previous_query_bus
    Rails.configuration.event_registry = @previous_event_registry
    result
  end

  def execute_command(command)
    command_bus.call(command)
  end
end
