require "heroes/creature_recruitment/configuration"
require "heroes/astrologers/configuration"
require "heroes/calendar/configuration"

module Heroes
  class Configuration
    def initialize(astrologers_available_symbols_provider, astrologers_growth_provider)
      @astrologers_available_symbols_provider = astrologers_available_symbols_provider
      @astrologers_growth_provider = astrologers_growth_provider
    end

    def call(event_store, command_bus, query_bus, event_mapper)
      configure_modules(event_store, command_bus, event_mapper)
    end

    def configure_modules(event_store, command_bus, event_mapper)
      [
        Heroes::CreatureRecruitment::Configuration.new,
        Heroes::Astrologers::Configuration.new(@astrologers_available_symbols_provider, @astrologers_growth_provider),
        Heroes::Calendar::Configuration.new
      ].each { |c| c.call(event_store, command_bus, event_mapper) }
    end
  end
end
