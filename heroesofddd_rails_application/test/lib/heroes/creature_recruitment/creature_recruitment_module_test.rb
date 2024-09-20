require "in_memory_event_store_test_case"
require "real_event_store_integration_test_case"

module Heroes
  module CreatureRecruitment
    class CreatureRecruitmentModuleTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :CRYSTAL, 1 ])
      end

      def test_given_nothing_when_build_dwelling_then_success
        # given
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)

        # when
        action = -> { execute_command(build_dwelling) }

        # then
        assert_nothing_raised(&action)
      end

      def test_given_dwelling_built_when_build_dwelling_then_success
        # given
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling)

        # when
        action = -> { execute_command(build_dwelling) }

        # then
        assert_nothing_raised(&action)
        read_model = DwellingReadModel.find_by(id: @dwelling_id)
        assert_not_nil(read_model)
      end

      def test_events
        # given
        stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"
        publish_event(stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling)

        # then
        assert_event_count_in_stream(stream_name, store_event_class(DwellingBuilt), 1)
      end

      private

      def publish_event(stream_name, domain_event)
        store_event = event_mapper.domain_to_store(domain_event)
        event_store.publish(store_event, stream_name: stream_name)
      end

      def assert_event_present(event_class, data)
        events = event_store.read.of_type(event_class).to_a
        assert_event_matches(events, event_class, data)
      end

      def assert_event_stream_contains(stream_name, event_class, data)
        events = event_store.read.stream(stream_name).of_type(event_class).to_a
        assert_event_matches(events, event_class, data)
      end

      def assert_event_count(event_class, expected_count)
        actual_count = event_store.read.of_type(event_class).to_a.size
        assert_equal expected_count, actual_count, "Expected #{expected_count} #{event_class} events, but found #{actual_count}."
      end

      def event_store
        Rails.configuration.event_store
      end

      def assert_event_matches(events, event_class, data)
        matching_event = events.find do |event|
          data.all? { |key, value| event.data[key] == value }
        end
        assert matching_event, "Expected to find a #{event_class} event with data #{data}, but none was found."
      end

      def assert_event_count_in_stream(stream_name, event_class, expected_count)
        actual_count = event_store.read.stream(stream_name).of_type(event_class).to_a.size
        assert_equal expected_count, actual_count, "Expected #{expected_count} #{event_class} events in stream #{stream_name}, but found #{actual_count}."
      end
    end
  end
end
