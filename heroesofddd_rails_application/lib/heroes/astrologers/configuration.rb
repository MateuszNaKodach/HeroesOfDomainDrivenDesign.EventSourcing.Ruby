require "building_blocks/infrastructure/event_sourcing_application_service"
require "heroes/astrologers/write/week_symbol"
require "heroes/astrologers/write/proclaim_week_symbol/command_proclaim_week_symbol"

module Heroes
  module Astrologers
    class Configuration
      def call(event_store, command_bus, event_registry)
        application_service = ::BuildingBlocks::Infrastructure::EventSourcingApplicationService.new(
          WeekSymbol,
          event_store,
          event_registry
        ) { |command| "Astrologers::WeekSymbols" }

        command_bus.register(
          ProclaimWeekSymbol,
          ProclaimWeekSymbolCommandHandler.new(application_service, event_registry)
        )
      end
    end
  end
end
