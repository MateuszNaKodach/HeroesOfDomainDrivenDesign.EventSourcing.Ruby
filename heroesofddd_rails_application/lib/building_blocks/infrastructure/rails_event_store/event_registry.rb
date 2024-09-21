module BuildingBlocks
  module Infrastructure
    module RailsEventStore
      class EventRegistry
        def initialize
          super
        end

        def map_event_type(domain_class, storage_class = nil, to_storage = nil, to_domain = nil) end

        def domain_to_store(domain_event)
          domain_event
        end
      end
    end
  end
end