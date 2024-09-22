class Configuration
  def call(event_store, command_bus, query_bus, event_registry)
    Heroes::Configuration.new.call(event_store, command_bus, query_bus, event_registry)
  end

  private
end
