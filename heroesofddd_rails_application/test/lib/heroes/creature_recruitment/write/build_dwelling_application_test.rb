require "in_memory_event_store_test_case"
require "real_event_store_integration_test_case"
require "heroes/creature_recruitment/write/build_dwelling/command_build_dwelling"
require "heroes/creature_recruitment/write/build_dwelling/rule_only_not_built"
require "heroes/shared_kernel/resources"

module Heroes
  module CreatureRecruitment
    class BuildDwellingApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])
        @stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"
      end

      def test_given_nothing_when_build_dwelling_then_success
        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling)

        # then
        expected_event = DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop)
        then_domain_event(@stream_name, expected_event)
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
    end
  end
end
