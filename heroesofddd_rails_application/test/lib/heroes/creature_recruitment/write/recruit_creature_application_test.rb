require "real_event_store_integration_test_case"
require "heroes/creature_recruitment/write/recruit_creature/command_recruit_creature"
require "heroes/creature_recruitment/write/recruit_creature/rule_not_exceed_available_creatures"
require "heroes/shared_kernel/resources"
require "building_blocks/application/app_context"

module Heroes
  module CreatureRecruitment
    class RecruitCreatureApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])

        @game_id = SecureRandom.uuid
        @stream_name ="Game::$#{@game_id}::CreatureRecruitment::Dwelling$#{@dwelling_id}"
        @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
      end

      def test_given_not_built_dwelling_when_recruit_creature_then_failed
        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 1)

        # then
        assert_raises(RecruitCreaturesNotExceedAvailableCreatures) do
          execute_command(recruit_creature, @app_context)
        end
      end

      def test_given_built_but_empty_dwelling_when_recruit_creature_then_failed
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 1)

        # then
        assert_raises(RecruitCreaturesNotExceedAvailableCreatures) do
          execute_command(recruit_creature, @app_context)
        end
      end

      def test_given_dwelling_with_1_creature_when_recruit_1_creature_then_success
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
        given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 1))

        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 1)
        execute_command(recruit_creature, @app_context)

        # then
        expected_event = CreatureRecruited.new(@dwelling_id, @creature_id, 1, @cost_per_troop)
        then_domain_event(@stream_name, expected_event)
      end

      def test_given_dwelling_with_3_creature_when_recruit_2_creature_then_success
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
        given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 3))

        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 2)
        execute_command(recruit_creature, @app_context)

        # then
        expected_cost = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 6000 ], [ :GEM, 2 ])
        expected_event = CreatureRecruited.new(@dwelling_id, @creature_id, 2, expected_cost)
        then_domain_event(@stream_name, expected_event)
      end

      def test_given_dwelling_when_recruit_creature_not_from_this_dwelling_then_failed
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
        given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 3))

        # when
        another_creature_id = SecureRandom.uuid
        recruit_creature = RecruitCreature.new(@dwelling_id, another_creature_id, 1)

        # then
        assert_raises(RecruitCreaturesNotExceedAvailableCreatures) do
          execute_command(recruit_creature, @app_context)
        end
      end

      def test_given_dwelling_with_recruited_all_available_creatures_at_once_when_recruit_creature_then_failed
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
        given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 5))
        given_domain_event(@stream_name, CreatureRecruited.new(@dwelling_id, @creature_id, 5, @cost_per_troop * 5))

        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 1)

        # then
        assert_raises(RecruitCreaturesNotExceedAvailableCreatures) do
          execute_command(recruit_creature, @app_context)
        end
      end

      def default_app_context
        @app_context
      end
    end
  end
end
