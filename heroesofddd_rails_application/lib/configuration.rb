class Configuration
  def call(event_store, command_bus, query_bus)
    Heroes::Configuration.new.call(event_store, command_bus, query_bus)
  end

  private
end
