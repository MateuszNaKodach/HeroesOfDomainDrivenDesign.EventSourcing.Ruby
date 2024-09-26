require "real_event_store_integration_test_case"
require "heroes/creature_recruitment/write/build_dwelling/command_build_dwelling"
require "heroes/creature_recruitment/write/build_dwelling/rule_only_not_built"
require "heroes/shared_kernel/resources"
require "building_blocks/application/app_context"

module Heroes
  module CreatureRecruitment
    class BuildDwellingApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])

        @game_id = SecureRandom.uuid
        @stream_name ="Game::$#{@game_id}::CreatureRecruitment::Dwelling$#{@dwelling_id}"
        @metadata = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
      end

      def test_given_nothing_when_build_dwelling_then_success
        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        execute_command(build_dwelling, @metadata)

        # then
        expected_event = DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop)
        then_domain_event(@stream_name, expected_event)
      end

      def test_given_dwelling_built_when_build_same_dwelling_one_more_time_then_failure_and_event_not_duplicated
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        build_dwelling = BuildDwelling.new(@dwelling_id, @creature_id, @cost_per_troop)
        assert_raises(OnlyNotBuiltBuildingCanBeBuild) do
          execute_command(build_dwelling,  @metadata)
        end

        # then
        then_stored_events_count(@stream_name, EventStore::Heroes::CreatureRecruitment::DwellingBuilt, 1)
      end

      def game_metadata
        @metadata
      end
    end
  end
end
