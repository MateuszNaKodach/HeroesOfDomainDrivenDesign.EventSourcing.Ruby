module Heroes
  module Astrologers
    class WhenWeekSymbolProclaimedThenIncreaseDwellingAvailableCreatures
      def initialize(event_store, command_bus, event_registry)
        @event_store = event_store
        @command_bus = command_bus
        @event_registry = event_registry
        @event_store.subscribe(
          self,
          to: [
            ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt,
            ::EventStore::Heroes::Astrologers::WeekSymbolProclaimed
          ]
        )
      end

      def call(event)
        game_id = event.metadata[:game_id]
        state = build_state(event, game_id)
        if week_symbol_proclaimed?(event)
          increase_available_creatures_for_week_symbol(event, state, game_id)
        end
      rescue => e
        # Handle any exception
        puts "An error occurred: #{e.message}"
      end

      private

      def build_state(event, game_id)
        stream_name = "Game::$#{game_id}::Astrologers::WeekSymbolDwellingEffect"
        proclaimed_at = event.metadata[:timestamp]
        past_events = @event_store.read.stream(stream_name)
                                  .older_than(proclaimed_at)
                                  .to_a
        last_stored = past_events.size - 1
        @event_store.link(event.event_id, stream_name: stream_name, expected_version: last_stored)
        DwellingsToProcess.new(Hash.new).tap do |state|
          past_events.each { |ev| state.call(ev) }
          state.call(event)
        end
      rescue RubyEventStore::WrongExpectedEventVersion
        retry
      end

      def week_symbol_proclaimed?(event)
        event.instance_of?(::EventStore::Heroes::Astrologers::WeekSymbolProclaimed)
      end

      def increase_available_creatures_for_week_symbol(event, state, game_id)
        week_of = event.data[:week_of]
        growth = event.data[:growth]
        symbol_dwellings = state.dwellings[week_of]
        symbol_dwellings&.each do |dwelling_id|
          metadata = ::BuildingBlocks::Application::AppContext.for_game(game_id)
          command = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(dwelling_id, week_of, growth)
          @command_bus.call(command, metadata)
        end
      end

      DwellingsToProcess = Data.define(:dwellings) do
        def call(event)
          case event
          when ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt
            dwelling_id = event.data[:dwelling_id]
            creature_id = event.data[:creature_id]
            (dwellings[creature_id] ||= []) << dwelling_id
          end
        end
      end
    end
  end
end
