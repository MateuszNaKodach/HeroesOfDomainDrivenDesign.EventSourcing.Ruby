require "heroes/configuration"

class Configuration
  def call(event_store, command_bus, query_bus, event_registry)
    Heroes::Configuration.new(
      Rails.configuration.astrologers_available_symbols_provider,
      Rails.configuration.astrologers_growth_provider
    ).call(event_store, command_bus, query_bus, event_registry)
  end

  private
end
