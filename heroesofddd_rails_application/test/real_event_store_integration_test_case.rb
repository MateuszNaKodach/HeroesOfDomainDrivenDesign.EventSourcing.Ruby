require "test_helper"

class RealEventStoreIntegrationTestCase < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  def execute_command(command)
    Rails.configuration.command_bus.call(command)
  end
end
