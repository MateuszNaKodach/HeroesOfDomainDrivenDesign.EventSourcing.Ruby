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

      def test_equality_event
        event_1 = DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop)
        event_2 = DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop)
        assert_equal event_1, event_2
      end

      def test_equality_cost
        cost_1 = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :CRYSTAL, 1 ])
        cost_2 = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :CRYSTAL, 1 ])
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

      def test_given_dwelling_built_when_build_dwelling_then_failure
        # given
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling)

        # when
        action = -> { execute_command(build_dwelling) }

        # then
        assert_raise(&action)
        #read_model = DwellingReadModel.find_by(id: @dwelling_id)
        #assert_not_nil(read_model)
      end

      def test_given_dwelling_built_when_build_same_dwelling_one_more_time_then_failure_and_event_not_duplicated
        # given
        stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"
        given_domain_event(stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        assert_raises(OnlyNotBuiltBuildingCanBeBuild) do
          execute_command(build_dwelling)
        end

        # then
        then_stored_events_count(stream_name, EventStore::Heroes::CreatureRecruitment::DwellingBuilt, 1)
      end

      def test_given_nothing_when_build_dwelling_then_success_event
        # given
        stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"

        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling)

        # then - problem - whole event here is a hash!
        then_stored_event(stream_name, EventStore::Heroes::CreatureRecruitment::DwellingBuilt, {
          dwelling_id: @dwelling_id,
          creature_id: @creature_id,
          cost_per_troop: { resources: { GOLD: 3000, CRYSTAL: 1 } }
        })
      end

      TestEvent = Class.new(RailsEventStore::Event)

      def test_serialization
        # given
        stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"

        # when
        build_dwelling = TestEvent.new(data: { dwelling_id: @dwelling_id, creature_id: @creature_id, cost_per_troop: @cost_per_troop })
        given_domain_event(stream_name, build_dwelling)

        # then - problem - whole event here is a hash!
        then_stored_event(stream_name, TestEvent, {
          dwelling_id: @dwelling_id,
          creature_id: @creature_id,
          cost_per_troop: { resources: { GOLD: 3000, CRYSTAL: 1 } }
        })
      end
    end
  end
end
