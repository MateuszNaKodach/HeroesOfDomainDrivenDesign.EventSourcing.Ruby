require "test_helper"
require "recording_command_bus"

class RealEventStoreIntegrationTestCase < ActionDispatch::IntegrationTest
  include EventStoreTest
  self.use_transactional_tests = false

  def before_setup
    result = super
    @previous_command_bus = Rails.configuration.command_bus
    @recording_command_bus = ::RecordingCommandBus.new(@previous_command_bus)
    Rails.configuration.command_bus = @recording_command_bus
    Configuration.new.call(Rails.configuration.event_store, Rails.configuration.command_bus, Rails.configuration.command_bus, Rails.configuration.event_registry)
    result
  end

  def before_teardown
    result = super
    @recording_command_bus.reset
    Rails.configuration.command_bus = @previous_command_bus
    result
  end

  def execute_command(command)
    command_bus.call(command)
  end
end
