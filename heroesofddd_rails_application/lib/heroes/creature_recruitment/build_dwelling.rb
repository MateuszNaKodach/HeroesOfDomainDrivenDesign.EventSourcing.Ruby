module Heroes
  module CreatureRecruitment
    BuildDwelling = Data.define(:dwelling_id, :creature_id, :cost_per_troop)
    DwellingBuilt = Data.define(:dwelling_id, :creature_id, :cost_per_troop)

    class BuildDwellingCommandHandler
      def initialize(event_store)
        @event_store = event_store
      end

      def call(command)
        stream_name = stream_name(command.dwelling_id)
        stored_events = @event_store
                          .read
                          .stream(stream_name)
        state = state_from(stored_events)

        result_events = Dwelling.decide(command, state)

        infra_events = result_events.map { |event| domain_to_store(event) }
        expected_stream_version = stored_events.count - 1
        @event_store.publish(infra_events, stream_name: stream_name, expected_version: expected_stream_version)
      end

      private

      def stream_name(dwelling_id)
        "CreatureRecruitment::Dwelling$#{dwelling_id}"
      end

      def state_from(events)
        events.reduce(Dwelling.initial_state) do |state, event|
          Dwelling.evolve(state, store_to_domain(event))
        end
      end

      private

      def domain_to_store(domain_event)
        ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt.from_domain(domain_event)
      end

      def store_to_domain(stored_event)
        ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt.to_domain(stored_event)
      end
    end
  end
end

module EventStore
  module Heroes
    module CreatureRecruitment
      DwellingBuilt = Class.new(RailsEventStore::Event) do
        def self.from_domain(domain_event)
          ::EventStore::Heroes::CreatureRecruitment::DwellingBuilt.new(
            data: {
              dwelling_id: domain_event.dwelling_id,
              creature_id: domain_event.creature_id,
              cost_per_troop: domain_event.cost_per_troop
            }
          )
        end

        def self.to_domain(stored_event)
          @data = stored_event.data
          ::Heroes::CreatureRecruitment::DwellingBuilt.new(
            dwelling_id: @data.fetch(:dwelling_id),
            creature_id: @data.fetch(:creature_id),
            cost_per_troop: @data.fetch(:cost_per_troop)
          )
        end
      end
    end
  end
end
