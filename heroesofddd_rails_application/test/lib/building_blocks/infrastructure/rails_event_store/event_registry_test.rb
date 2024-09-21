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
      end
    end
  end
end
