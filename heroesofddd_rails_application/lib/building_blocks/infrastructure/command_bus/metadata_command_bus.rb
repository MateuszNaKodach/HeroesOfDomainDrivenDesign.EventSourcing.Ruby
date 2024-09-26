module BuildingBlocks
  module Infrastructure
    module CommandBus
      class MetadataCommandBus

        def initialize(decorated, event_store)
          @decorated = decorated
          @event_store = event_store
        end

        def call(command, metadata = nil)
          if metadata.nil?
            @decorated.call(command)
          else
            @event_store.with_metadata(**metadata.to_h) do
              @decorated.call(command)
            end
          end
        end

        def register(command, handler)
          @decorated.register(command, handler)
        end

      end
    end
  end
end