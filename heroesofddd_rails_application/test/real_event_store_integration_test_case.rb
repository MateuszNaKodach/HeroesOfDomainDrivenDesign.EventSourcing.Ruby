require "test_helper"

class RealEventStoreIntegrationTestCase < ActionDispatch::IntegrationTest
  include EventStoreTest
  self.use_transactional_tests = false

  def execute_command(command, metadata = nil)
    # command_bus.call(command, metadata || game_metadata)
    command_bus.call(command, metadata)
  end

  def before_setup
    result = super
    @recording_command_bus = Rails.configuration.command_bus
    result
  end

  def before_teardown
    result = super
    @recording_command_bus.reset
    result
  end
end
