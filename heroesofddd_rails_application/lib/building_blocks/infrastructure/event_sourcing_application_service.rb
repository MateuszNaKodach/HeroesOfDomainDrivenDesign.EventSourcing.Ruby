module BuildingBlocks
  module Infrastructure
    class EventSourcingApplicationService
      def initialize(decider, event_store, event_registry, &command_to_stream_name)
        @decider = decider
        @event_store = event_store
        @event_registry = event_registry
        @command_to_stream_name = command_to_stream_name
      end

      def call(command)
        metadata = @event_store.metadata
        stream_name = @command_to_stream_name.call(command, metadata)
        stored_events = @event_store
                          .read
                          .stream(stream_name)
        state = state_from(stored_events)

        result_events = @decider.decide(command, state)

        events_to_store = result_events.map { |event| @event_registry.domain_to_store(event) }
        expected_stream_version = stored_events.count - 1
        @event_store.publish(events_to_store, stream_name: stream_name, expected_version: expected_stream_version)
      end

      private

      def state_from(stored_events)
        stored_events.reduce(@decider.initial_state) do |state, event|
          @decider.evolve(state, @event_registry.store_to_domain(event))
        end
      end
    end
  end
end
