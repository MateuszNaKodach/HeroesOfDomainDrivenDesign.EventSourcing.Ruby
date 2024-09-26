require "test_helper"

class RealEventStoreIntegrationTestCase < ActionDispatch::IntegrationTest
  include EventStoreTest
  self.use_transactional_tests = false

  def execute_command(command, metadata = nil)
    command_bus.call(command, metadata)
  end
end
