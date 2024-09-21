module Heroes
  module CreatureRecruitment
    BuildDwelling = Data.define(:dwelling_id, :creature_id, :cost_per_troop)
    DwellingBuilt = Data.define(:dwelling_id, :creature_id, :cost_per_troop)

    class BuildDwellingCommandHandler
      def initialize(event_store, event_type_mapper)
        @event_store = event_store
        @event_type_mapper = event_type_mapper
        @event_type_mapper.add_event_type(DwellingBuilt)
      end

      def call(command)
        stream_name = stream_name(command.dwelling_id)
        stored_events = @event_store
                          .read
                          .stream(stream_name)
        state = state_from(stored_events)

        result_events = Dwelling.decide(command, state)

        infra_events = result_events.map { |event| @event_type_mapper.domain_to_store(event) }
        expected_stream_version = stored_events.count - 1
        @event_store.publish(infra_events, stream_name: stream_name, expected_version: expected_stream_version)
      end

      private

      def stream_name(dwelling_id)
        "CreatureRecruitment::Dwelling$#{dwelling_id}"
      end

      def state_from(events)
        events.reduce(Dwelling.initial_state) do |state, event|
          Dwelling.evolve(state, @event_type_mapper.store_to_domain(event))
        end
      end
    end
  end
end

module EventStore
  module Heroes
    module CreatureRecruitment
    end
  end
end
