module BuildingBlocks
  module Infrastructure
    module RailsEventStore
      class EventMapper
        def initialize
          @domain_to_store_mappings = {}
          @store_to_domain_mappings = {}
        end

        def add_event_type(domain_class)
          store_class = create_store_event_class(domain_class)
          @domain_to_store_mappings[domain_class] = store_class
          @store_to_domain_mappings[store_class] = domain_class
        end

        def domain_to_store_class(domain_class)
          @domain_to_store_mappings[domain_class]
        end

        def store_to_domain_class(infra_class)
          @store_to_domain_mappings[infra_class]
        end

        def domain_to_store(event)
          infra_class = domain_to_store_class(event.class)
          #data = event_to_data(event)
          infra_class.new(data: event)
        end

        def store_to_domain(event)
          domain_class = store_to_domain_class(event.class)
          domain_class.new(**event.data.transform_keys(&:to_sym))
        end

        private

        def create_store_event_class(domain_class)
          domain_module_parts = domain_class.name.split("::")
          event_name = domain_module_parts.pop
          domain_module_name = domain_module_parts.join("::")

          infra_module_name = domain_module_name.empty? ? "EventStore" : "EventStore::#{domain_module_name}"
          infra_module = Object.const_get(infra_module_name)

          infra_module.const_set(event_name, Class.new(RubyEventStore::Event))
        end

        def event_to_data(event)
          if event.respond_to?(:to_h)
            event.to_h
          else
            event.instance_variables.each_with_object({}) do |var, hash|
              key = var.to_s.delete("@")
              hash[key] = event.instance_variable_get(var)
            end
          end
        end
      end
    end
  end
end