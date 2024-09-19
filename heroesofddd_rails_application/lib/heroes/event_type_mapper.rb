module Heroes
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
end
