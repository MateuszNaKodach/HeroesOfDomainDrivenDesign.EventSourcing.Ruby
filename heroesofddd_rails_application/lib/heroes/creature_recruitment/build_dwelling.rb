module Heroes
  module CreatureRecruitment
    BuildDwelling = Data.define(:dwelling_id, :creature_id, :cost_per_troop)
    DwellingBuilt = Data.define(:dwelling_id, :creature_id, :cost_per_troop)

    class BuildDwellingCommandHandler
      def initialize(event_store)
        @event_store = event_store # todo: make it private?
        @domain_module = Object.const_get("Heroes::CreatureRecruitment")
        @infra_module = Object.const_get("EventStore::Heroes::CreatureRecruitment")
        @event_classes = [ :DwellingBuilt ]
        setup_event_mappings
      end

      def call(command)
        stream_name = stream_name(command.dwelling_id)
        stored_events = @event_store
          .read
          .stream(stream_name)
        state = state_from(stored_events)

        result_events = Dwelling.decide(command, state)

        expected_stream_version = stored_events.count - 1
        @event_store.publish(result_events.map(&method(:domain_to_infra_mapper)), stream_name: stream_name, expected_version: expected_stream_version)
      end

      private
      def stream_name(dwelling_id)
        "CreatureRecruitment::Dwelling#{dwelling_id}"
      end

      def state_from(events)
        events.reduce(Dwelling.initial_state) { |state, event| Dwelling.evolve(state, infra_to_domain_mapper(event)) }
      end

      def setup_event_mappings
        @event_mappings = {}
        @event_classes.each do |event_class|
          domain_class = @domain_module.const_get(event_class)
          infra_class = create_infra_event_class(event_class)
          @event_mappings[event_class.to_s] = {
            domain_class: domain_class,
            infra_class: infra_class
          }
        end
      end

      def create_infra_event_class(name)
        @infra_module.const_set(name, Class.new(RailsEventStore::Event))
      end

      def infra_to_domain_mapper(event)
        mapping = @event_mappings[event.event_type.split("::").last]
        domain_class = mapping[:domain_class]
        domain_class.new(**event.data.transform_keys(&:to_sym))
      end

      def domain_to_infra_mapper(event)
        mapping = @event_mappings[event.class.name.split("::").last]
        infra_class = mapping[:infra_class]

        data = if event.respond_to?(:to_h)
                 event.to_h
        else
                 event.instance_variables.each_with_object({}) do |var, hash|
                   key = var.to_s.delete("@")
                   hash[key] = event.instance_variable_get(var)
                 end
        end

        # If the event has no properties, data will be an empty hash
        infra_class.new(data: data)
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
