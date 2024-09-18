module Heroes
  module CreatureRecruitment
    BuildDwelling = Data.define(:dwelling_id, :creature_id, :cost_per_troop)
    DwellingBuilt = Data.define(:dwelling_id, :creature_id, :cost_per_troop) do
      def event_type
        "creature-recruitment:dwelling-built"
      end
    end

    class BuildDwellingCommandHandler
      def initialize(event_store)
        @event_store = event_store # todo: make it private?
      end

      def call(command)
        stream_name = stream_name(command.dwelling_id)
        stored_events = @event_store
          .read
          .stream(stream_name)
        state = state_from(stored_events)

        result_events = Dwelling.decide(command, state)

        expected_stream_version = stored_events.count
        @event_store.publish(result_events, stream_name: stream_name, expected_version: expected_stream_version)
      end

      private
      def stream_name(dwelling_id)
        "CreatureRecruitment::Dwelling#{dwelling_id}"
      end

      def state_from(events)
        events.reduce(Dwelling.initial_state) { |state, event| Dwelling.evolve(state, event) }
      end

    end
  end
end
