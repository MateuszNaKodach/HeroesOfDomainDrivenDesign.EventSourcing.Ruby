require "minitest/autorun"
require "rails_event_store"
require_relative "../../../../../lib/building_blocks/infrastructure/event_store/event_registry"

module BuildingBlocks
  module Infrastructure
    module EventStore
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
          event_registry = ::BuildingBlocks::Infrastructure::EventStore::EventRegistry.new
          event_registry.map_event_type(StorageEvent)

          # when
          event_instance = StorageEvent.new
          store_event = event_registry.domain_to_store(event_instance)

          assert_equal event_instance, store_event
        end

        def test_map_event_type_raises_exception_if_args_missing_for_non_event_class
          event_registry = ::BuildingBlocks::Infrastructure::EventStore::EventRegistry.new

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

        def test_domain_to_store_returns_non_event_object_for_non_event_domain_class
          event_registry = ::BuildingBlocks::Infrastructure::EventStore::EventRegistry.new

          # Provide all arguments for a non-RubyEventStore::Event domain class
          event_registry.map_event_type(DomainEvent, StorageEvent, ->(domain_event) { StorageEvent.new(data: domain_event) }, ->() { })

          # Create an instance of DomainEvent (which doesn't extend RubyEventStore::Event)
          domain_event = DomainEvent.new(value1: "test_value1", value2: NestedHash.new({ cost: { value: 10, currency: "PLN" } }))

          # Call domain_to_store
          store_event = event_registry.domain_to_store(domain_event)

          # Assert that the returned object is different from RubyEventStore::Event
          refute_equal domain_event, store_event
          refute_instance_of StorageEvent, domain_event
          assert_instance_of StorageEvent, store_event
        end

        def test_domain_to_store_maps_domain_event_to_storage_event_using_mapping_function
          event_registry = ::BuildingBlocks::Infrastructure::EventStore::EventRegistry.new

          # Provide all arguments for a non-RubyEventStore::Event domain class
          event_registry.map_event_type(
            DomainEvent,
            StorageEvent,
            ->(domain_event) {
              # Simulate mapping by creating a StorageEvent with data from DomainEvent
              StorageEvent.new(data: { value1: domain_event.value1, value2: domain_event.value2.hash_value })
            },
            ->() { }
          )

          # Create an instance of DomainEvent
          domain_event = DomainEvent.new(value1: "test_value1", value2: NestedHash.new({ cost: { value: 10, currency: "PLN" } }))

          # Call domain_to_store, which should invoke the to_storage lambda
          store_event = event_registry.domain_to_store(domain_event)

          # Verify that the store_event is a StorageEvent and contains the correct mapped data
          assert_instance_of StorageEvent, store_event
          assert_equal domain_event.value1, store_event.data[:value1]
          assert_equal domain_event.value2.hash_value, store_event.data[:value2]
        end

        def test_store_to_domain_round_trip_mapping
          event_registry = ::BuildingBlocks::Infrastructure::EventStore::EventRegistry.new

          # Register mappings between DomainEvent and StorageEvent
          event_registry.map_event_type(
            DomainEvent,
            StorageEvent,
            ->(domain_event) {
              # Map DomainEvent to StorageEvent
              StorageEvent.new(data: { value1: domain_event.value1, value2: domain_event.value2.hash_value })
            },
            ->(store_event) {
              # Map StorageEvent back to DomainEvent
              DomainEvent.new(value1: store_event.data[:value1], value2: NestedHash.new(store_event.data[:value2]))
            }
          )

          # Create an instance of DomainEvent
          original_domain_event = DomainEvent.new(value1: "test_value1", value2: NestedHash.new({ cost: { value: 10, currency: "PLN" } }))

          # Convert DomainEvent to StorageEvent
          store_event = event_registry.domain_to_store(original_domain_event)

          # Convert back from StorageEvent to DomainEvent
          restored_domain_event = event_registry.store_to_domain(store_event)

          # Assert that the original DomainEvent and the restored DomainEvent are equal
          assert_equal original_domain_event.value1, restored_domain_event.value1
          assert_equal original_domain_event.value2.hash_value, restored_domain_event.value2.hash_value
          assert_equal original_domain_event, restored_domain_event
        end

        def test_domain_to_store_with_complex_nested_object
          event_registry = ::BuildingBlocks::Infrastructure::EventStore::EventRegistry.new

          # Register mappings between DomainEvent and StorageEvent with nested objects
          event_registry.map_event_type(
            DomainEvent,
            StorageEvent,
            ->(domain_event) {
              # Properly flatten the structure in StorageEvent
              StorageEvent.new(data: {
                value1: domain_event.value1,
                value2: domain_event.value2.hash_value[:cost], # Ensure we map the correct level
                date: domain_event.value2.hash_value[:date],
                items: domain_event.value2.hash_value[:items]
              })
            },
            ->(store_event) {
              # Reconstruct the DomainEvent from StorageEvent
              DomainEvent.new(
                value1: store_event.data[:value1],
                value2: NestedHash.new({
                                         cost: store_event.data[:value2],
                                         date: store_event.data[:date],
                                         items: store_event.data[:items]
                                       })
              )
            }
          )

          complex_data = { cost: { value: 10, currency: "PLN" }, date: Date.today, items: [ "item1", "item2" ] }
          domain_event = DomainEvent.new(value1: "test_value1", value2: NestedHash.new(complex_data))

          store_event = event_registry.domain_to_store(domain_event)
          restored_domain_event = event_registry.store_to_domain(store_event)

          # Assert that the restored domain event is the same as the original
          assert_equal domain_event.value1, restored_domain_event.value1
          assert_equal domain_event.value2.hash_value, restored_domain_event.value2.hash_value
          assert_equal domain_event, restored_domain_event
        end

        def test_domain_to_store_with_date_time_and_symbols
          event_registry = ::BuildingBlocks::Infrastructure::EventStore::EventRegistry.new

          # Register mappings between DomainEvent and StorageEvent with different Ruby types
          event_registry.map_event_type(
            DomainEvent,
            StorageEvent,
            ->(domain_event) {
              # Properly map domain to store event with Date, Time, and Symbol
              StorageEvent.new(data: {
                value1: domain_event.value1,
                value2: domain_event.value2.hash_value[:cost],  # Flatten cost
                created_at: domain_event.value2.hash_value[:created_at],  # Time object
                status: domain_event.value2.hash_value[:status]  # Symbol
              })
            },
            ->(store_event) {
              # Map the storage event back to the domain event
              DomainEvent.new(
                value1: store_event.data[:value1],
                value2: NestedHash.new({
                                         cost: store_event.data[:value2],
                                         created_at: store_event.data[:created_at],
                                         status: store_event.data[:status]
                                       })
              )
            }
          )

          # Create an instance of DomainEvent with Date, Time, and Symbol
          current_time = Time.now
          domain_event = DomainEvent.new(
            value1: "test_value1",
            value2: NestedHash.new({
                                     cost: { value: 10, currency: "PLN" },
                                     created_at: current_time,  # Time object
                                     status: :active  # Symbol
                                   })
          )

          # Convert DomainEvent to StorageEvent
          store_event = event_registry.domain_to_store(domain_event)

          # Convert back from StorageEvent to DomainEvent
          restored_domain_event = event_registry.store_to_domain(store_event)

          # Assert that the original DomainEvent and the restored DomainEvent are equal
          assert_equal domain_event.value1, restored_domain_event.value1
          assert_equal domain_event.value2.hash_value[:cost], restored_domain_event.value2.hash_value[:cost]
          assert_equal domain_event.value2.hash_value[:created_at].to_i, restored_domain_event.value2.hash_value[:created_at].to_i  # Compare time in seconds
          assert_equal domain_event.value2.hash_value[:status], restored_domain_event.value2.hash_value[:status]  # Symbol comparison
          assert_equal domain_event, restored_domain_event
        end
      end
    end
  end
end
