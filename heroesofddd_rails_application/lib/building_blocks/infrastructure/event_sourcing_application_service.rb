module BuildingBlocks
  module Infrastructure
    class EventSourcingApplicationService
      def initialize(decider, event_store, &command_to_stream_id)
        @decider = decider
        @event_store = event_store
      end
    end
  end
end
