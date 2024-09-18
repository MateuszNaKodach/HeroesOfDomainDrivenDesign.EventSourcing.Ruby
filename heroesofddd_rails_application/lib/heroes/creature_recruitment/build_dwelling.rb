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
        @event_store.publish(result_events.map(&method(:domain_to_infra_mapper)), stream_name: stream_name, expected_version: expected_stream_version)
      end

      private
      def stream_name(dwelling_id)
        "CreatureRecruitment::Dwelling#{dwelling_id}"
      end

      def state_from(events)
        events.reduce(Dwelling.initial_state) { |state, event| DECIDER.evolve(state, event) }
      end

      def domain_to_infra_mapper(event)
        event_class_name = event.class.name.split("::").last
        infra_event_class = Object.const_get("Heroes::CreatureRecruitment::#{event_class_name}")
        #infra_event_class = Object.const_get(event.event_type)

        infra_event_class.new(
          data: event_to_data(event)
        )
      end

      def event_to_data(event)
        event.instance_variables.each_with_object({}) do |var, hash|
          key = var.to_s.delete("@").to_sym
          value = event.instance_variable_get(var)

          hash[key] = value
        end
      end

    end
  end
end
