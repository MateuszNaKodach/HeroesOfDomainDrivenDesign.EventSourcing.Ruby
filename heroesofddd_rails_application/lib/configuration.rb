class Configuration
  def call(event_store, command_bus, query_bus, event_mapper)
    Heroes::Configuration.new.call(event_store, command_bus, query_bus, event_mapper)
  end

  private
end
