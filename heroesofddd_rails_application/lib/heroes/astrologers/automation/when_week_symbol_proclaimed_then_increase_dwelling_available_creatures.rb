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
        state = build_state(event)
        if week_symbol_proclaimed?(event)
          increase_available_creatures_for_week_symbol(event, state)
        end
      end

      private

      def build_state(event)
        stream_name = "Astrologers::WeekSymbolDwellingEffect"
        past_events = @event_store.read.stream(stream_name).to_a
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

      def increase_available_creatures_for_week_symbol(event, state)
        week_of = event.data[:week_of]
        growth = event.data[:growth]
        symbol_dwellings = state.dwellings[week_of]
        symbol_dwellings.each do |dwelling_id|
          @command_bus.call(::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(dwelling_id, week_of, growth))
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
