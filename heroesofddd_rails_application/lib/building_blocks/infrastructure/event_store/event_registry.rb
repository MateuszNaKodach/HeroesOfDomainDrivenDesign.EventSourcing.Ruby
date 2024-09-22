module BuildingBlocks
  module Infrastructure
    module EventStore
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

        def store_to_domain(store_event)
          mapping = @mappings.values.find { |m| m[:storage_class] == store_event.class }

          if mapping && !mapping[:to_domain].nil?
            # Use the provided to_domain lambda to map the store event back to a domain event
            mapping[:to_domain].call(store_event)
          else
            # Default case, return the event as is (for RubyEventStore::Event)
            store_event
          end
        end
      end
    end
  end
end