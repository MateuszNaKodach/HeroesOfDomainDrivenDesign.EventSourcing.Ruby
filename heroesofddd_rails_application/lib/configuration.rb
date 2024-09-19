class Configuration
  def call(event_store, command_bus)
    Heroes::Configuration.new.call(event_store, command_bus)
  end

  private
end
