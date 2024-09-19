require "test_helper"

class RealEventStoreIntegrationTestCase < ActionDispatch::IntegrationTest

  def execute_command(command)
    Rails.configuration.command_bus.call(command)
  end
end
