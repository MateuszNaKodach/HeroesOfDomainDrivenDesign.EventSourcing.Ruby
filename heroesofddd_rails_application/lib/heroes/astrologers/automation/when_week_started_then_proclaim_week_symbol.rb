module Heroes
  module Astrologers
    class WhenWeekStartedThenProclaimWeekSymbol
      def initialize(event_store, command_bus, astrologers_available_symbols_provider, astrologers_growth_provider)
        @event_store = event_store
        @command_bus = command_bus
        @astrologers_available_symbols_provider = astrologers_available_symbols_provider
        @astrologers_growth_provider = astrologers_growth_provider
        @event_store.subscribe(self, to: [ ::EventStore::Heroes::Calendar::DayStarted ])
      end

      def call(event)
        return unless event.data[:day] == 1

        game_id = event.metadata[:game_id]
        command = Heroes::Astrologers::ProclaimWeekSymbol.new(
          month: event.data[:month],
          week: event.data[:week],
          week_of: @astrologers_available_symbols_provider.call,
          growth: @astrologers_growth_provider.call
        )

        @command_bus.call(command, ::BuildingBlocks::Application::AppContext.for_game(game_id))
      end
    end
  end
end
