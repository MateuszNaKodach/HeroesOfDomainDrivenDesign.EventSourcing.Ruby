module Heroes
  module CreatureRecruitment

    BuildDwelling = Data.define(:dwelling_id, :creature_id, :cost_per_troop)
    DwellingBuilt = Data.define(:dwelling_id, :creature_id, :cost_per_troop)

    class EventTypeMapper
      def initialize
        @event_mappings = {}
      end

      def add_event_type(event_class)
        domain_class = event_class
        infra_class = create_infra_event_class(event_class)
        @event_mappings[event_class.name.split("::").last] = {
          domain_class: domain_class,
          infra_class: infra_class
        }
      end

      def infra_to_domain(event)
        mapping = @event_mappings[event.event_type.split("::").last]
        domain_class = mapping[:domain_class]
        domain_class.new(**event.data.transform_keys(&:to_sym))
      end

      def domain_to_infra(event)
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

        infra_class.new(data: data)
      end

      private

      def create_infra_event_class(domain_class)
        domain_module_parts = domain_class.name.split("::")
        event_name = domain_module_parts.pop
        domain_module_name = domain_module_parts.join("::")

        infra_module_name = domain_module_name.empty? ? "EventStore" : "EventStore::#{domain_module_name}"
        infra_module = Object.const_get(infra_module_name)

        infra_module.const_set(event_name, Class.new(RubyEventStore::Event))
      end
    end

    class BuildDwellingCommandHandler
      def initialize(event_store)
        @event_store = event_store
        @event_type_mapper = EventTypeMapper.new
        setup_event_mappings
      end

      def call(command)
        stream_name = stream_name(command.dwelling_id)
        stored_events = @event_store
                          .read
                          .stream(stream_name)
        state = state_from(stored_events)

        result_events = Dwelling.decide(command, state)

        infra_events = result_events.map { |event| @event_type_mapper.domain_to_infra(event) }
        expected_stream_version = stored_events.count - 1
        @event_store.publish(infra_events, stream_name: stream_name, expected_version: expected_stream_version)
      end

      private

      def stream_name(dwelling_id)
        "CreatureRecruitment::Dwelling$#{dwelling_id}"
      end

      def state_from(events)
        events.reduce(Dwelling.initial_state) do |state, event|
          Dwelling.evolve(state, @event_type_mapper.infra_to_domain(event))
        end
      end

      def setup_event_mappings
        @event_type_mapper.add_event_type(DwellingBuilt)
        # Add other event types as needed
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