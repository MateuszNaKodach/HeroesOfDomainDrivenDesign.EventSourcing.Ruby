module BuildingBlocks
  module Infrastructure
    module RailsEventStore
      class EventRegistry
        def initialize
          super
        end

        def map_event_type(domain_class, storage_class = nil, to_storage = nil, to_domain = nil)
          unless domain_class.ancestors.include?(RubyEventStore::Event)
            if storage_class.nil? || to_storage.nil? || to_domain.nil?
              raise ArgumentError, "storage_class, to_storage, and to_domain must be provided for non-RubyEventStore::Event classes"
            end
          end
        end

        def domain_to_store(domain_event)
          domain_event
        end
      end
    end
  end
end