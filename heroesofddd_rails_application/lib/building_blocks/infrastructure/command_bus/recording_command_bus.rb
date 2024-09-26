module BuildingBlocks
  module Infrastructure
    module CommandBus
      class RecordingCommandBus
        attr_reader :recorded

        def initialize(decorated)
          @recorded = []
          @decorated = decorated
        end

        def call(command, metadata)
          @recorded << command
          @decorated.call(command, metadata)
        end

        def reset
          @recorded = []
        end

        def register(command, handler)
          @decorated.register(command, handler)
        end
      end
    end
  end
end
