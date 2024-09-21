module BuildingBlocks
  module Infrastructure
    module RailsEventStore
      class EventRegistry
        def initialize
          super
          @mappings = {}
        end

        def map_event_type(domain_class, storage_class = nil, to_storage = nil, to_domain = nil)
          unless domain_class.ancestors.include?(RubyEventStore::Event)
            if storage_class.nil? || to_storage.nil? || to_domain.nil?
              raise ArgumentError, "storage_class, to_storage, and to_domain must be provided for non-RubyEventStore::Event classes"
            end
          end

          @mappings[domain_class] = { storage_class: storage_class, to_storage: to_storage, to_domain: to_domain }
        end

        def domain_to_store(domain_event)
          mapping = @mappings[domain_event.class]

          if mapping && !mapping[:to_storage].nil?
            # Use the provided to_storage lambda to map the domain event to a store event
            mapping[:to_storage].call(domain_event)
          else
            # Default case, return the event as is (for RubyEventStore::Event)
            domain_event
          end
        end
      end
    end
  end
end