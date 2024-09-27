require "building_blocks/infrastructure/event_sourcing_application_service"
require "heroes/astrologers/write/week_symbol"
require "heroes/astrologers/write/proclaim_week_symbol/command_proclaim_week_symbol"
require "heroes/astrologers/automation/when_week_symbol_proclaimed_then_increase_dwelling_available_creatures"
require "heroes/astrologers/automation/when_week_started_then_proclaim_week_symbol"

module Heroes
  module Astrologers
    class Configuration

      def initialize(astrologers_available_symbols_provider, astrologers_growth_provider)
        @astrologers_available_symbols_provider = astrologers_available_symbols_provider
        @astrologers_growth_provider = astrologers_growth_provider
      end

      def call(event_store, command_bus, event_registry)
        application_service = ::BuildingBlocks::Infrastructure::EventSourcingApplicationService.new(
          WeekSymbol,
          event_store,
          event_registry
        ) { |_, metadata| "Game::$#{metadata[:game_id]}::Astrologers::WeekSymbols" }

        command_bus.register(
          ProclaimWeekSymbol,
          ProclaimWeekSymbolCommandHandler.new(application_service, event_registry)
        )

        WhenWeekSymbolProclaimedThenIncreaseDwellingAvailableCreatures.new(event_store, command_bus, event_registry)
        WhenWeekStartedThenProclaimWeekSymbol.new(event_store, command_bus, @astrologers_available_symbols_provider, @astrologers_growth_provider)
      end
    end
  end
end
