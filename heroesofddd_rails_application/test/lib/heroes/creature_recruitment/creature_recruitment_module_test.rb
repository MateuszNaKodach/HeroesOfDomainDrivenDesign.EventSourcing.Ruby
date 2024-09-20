require "in_memory_event_store_test_case"
require "real_event_store_integration_test_case"

module Heroes
  module CreatureRecruitment
    class CreatureRecruitmentModuleTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([:GOLD, 3000], [:CRYSTAL, 1])
      end

      def test_equality_event
        event_1 = DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop)
        event_2 = DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop)
        assert_equal event_1, event_2
      end

      def test_equality_cost
        cost_1 = Heroes::SharedKernel::Resources::Cost.resources([:GOLD, 3000], [:CRYSTAL, 1])
        cost_2 = Heroes::SharedKernel::Resources::Cost.resources([:GOLD, 3000], [:CRYSTAL, 1])
        assert_equal cost_1, cost_2
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

      def test_given_dwelling_built_when_build_same_dwelling_one_more_time_then_nothing
        # given
        stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"
        publish_event(stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling)

        # then
        assert_event_count_in_stream(stream_name, store_event_class(DwellingBuilt), 1)
      end

      def test_given_nothing_when_build_dwelling_then_success_event
        # given
        stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"

        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling)

        # then - problem - whole event here is a hash! because we do the mapping of data to hash
        assert_event_stream_contains(stream_name, store_event_class(DwellingBuilt), {
          dwelling_id: @dwelling_id,
          creature_id: @creature_id,
          cost_per_troop: Heroes::SharedKernel::Resources::Cost.resources([:GOLD, 3000], [:CRYSTAL, 1])
        })
      end
    end
  end
end
