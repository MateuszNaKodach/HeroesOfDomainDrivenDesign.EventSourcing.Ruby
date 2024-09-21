require "minitest/autorun"
require "rails_event_store"
require_relative "../../../../../lib/building_blocks/infrastructure/rails_event_store/event_registry"

module BuildingBlocks
  module Infrastructure
    module RailsEventStore
      DomainEvent = Data.define(:value1, :value2)
      StorageEvent = Class.new(RubyEventStore::Event)
      NestedHash = Data.define(:hash_value)

      def setup
        @value1 = "String value"
        @value2 = NestedHash.new({ cost: { value: 10, currency: "PLN" } })
      end

      class EventRegistryTest < Minitest::Test
        def test_map_domain_to_store_for_domain_extends_rubyeventstore_event
          # given
          event_registry = ::BuildingBlocks::Infrastructure::RailsEventStore::EventRegistry.new
          event_registry.map_event_type(StorageEvent)

          # when
          event_instance = StorageEvent.new
          store_event = event_registry.domain_to_store(event_instance)

          assert_equal event_instance, store_event
        end

        def test_map_event_type_raises_exception_if_args_missing_for_non_event_class
          event_registry = ::BuildingBlocks::Infrastructure::RailsEventStore::EventRegistry.new

          # Case 1: No exception if domain_class extends RubyEventStore::Event and no other arguments are passed
          assert_silent do
            event_registry.map_event_type(StorageEvent)
          end

          # Case 2: Raise error if domain_class does not extend RubyEventStore::Event and arguments are nil
          assert_raises(ArgumentError) do
            event_registry.map_event_type(DomainEvent) # No other arguments
          end

          # Case 3: No exception if all arguments are provided for a non-RubyEventStore::Event class
          assert_silent do
            event_registry.map_event_type(DomainEvent, StorageEvent, ->(d) { d }, ->(s) { s })
          end

          # Case 4: Raise error if any argument is nil for a non-RubyEventStore::Event class
          assert_raises(ArgumentError) do
            event_registry.map_event_type(DomainEvent, nil, ->(d) { d }, ->(s) { s })
          end

          assert_raises(ArgumentError) do
            event_registry.map_event_type(DomainEvent, StorageEvent, nil, ->(s) { s })
          end

          assert_raises(ArgumentError) do
            event_registry.map_event_type(DomainEvent, StorageEvent, ->(d) { d }, nil)
          end
        end
      end
    end
  end
end
