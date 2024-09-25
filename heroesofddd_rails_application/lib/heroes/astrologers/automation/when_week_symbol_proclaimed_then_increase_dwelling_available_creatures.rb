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
        dwellings = build_state(event)
        if is_week_symbol_proclaimed(event)
          week_of = event[:week_of]
          growth = event[:growth]
          symbol_dwellings = dwellings[week_of]
          symbol_dwellings.each do |d|
            @command_bus.call(::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(d.dwelling_id, d.creature_id, growth))
          end
        end
      end

      def build_state(event)
        stream_name = "Astrologers::WeekSymbol$#{event.data.fetch(:order_id)}"
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

      def is_week_symbol_proclaimed(event)
        event.instance_of?(::EventStore::Heroes::Astrologers::WeekSymbolProclaimed)
      end

      DwellingsToProcess = Data.define(:dwellings) do
        def call(event)
          dwelling_id = event.data[:dwelling_id]
          creature_id = event.data[:creature_id]
          case event
          when ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt
            (dwellings[creature_id] ||= []) << dwelling_id
          end
        end
      end

    end
  end
end
