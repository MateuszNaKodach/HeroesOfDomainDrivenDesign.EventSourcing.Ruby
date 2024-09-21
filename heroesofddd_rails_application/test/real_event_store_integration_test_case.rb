require "test_helper"

class RealEventStoreIntegrationTestCase < ActionDispatch::IntegrationTest
  include EventStoreTest
  self.use_transactional_tests = false

  def execute_command(command)
    command_bus.call(command)
  end
end
