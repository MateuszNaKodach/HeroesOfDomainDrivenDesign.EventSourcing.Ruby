require "in_memory_event_store_test_case"
require "real_event_store_integration_test_case"
require "heroes/creature_recruitment/write/recruit_creature/command_recruit_creature"
require "heroes/creature_recruitment/write/recruit_creature/rule_not_exceed_available_creatures"
require "heroes/creature_recruitment/write/change_available_creatures/rule_only_built"
require "heroes/shared_kernel/resources"

module Heroes
  module CreatureRecruitment
    class IncreaseAvailableCreaturesApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])
        @stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"
      end

      def test_not_built_dwelling_when_change_available_creatures_then_failed
        # when
        recruit_creature = IncreaseAvailableCreatures.new(@dwelling_id, @creature_id, 10)

        # then
        assert_raises(OnlyBuiltDwellingCanHaveAvailableCreatures) do
          execute_command(recruit_creature)
        end
      end

      def test_built_dwelling_when_change_available_creatures_then_success
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        recruit_creature = IncreaseAvailableCreatures.new(@dwelling_id, @creature_id, 10)
        execute_command(recruit_creature)

        # then
        expected_event = AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 10)
        then_domain_event(@stream_name, expected_event)
      end

      def test_built_dwelling_with_available_creatures_when_change_available_creatures_then_success
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
        given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 1))

        # when
        recruit_creature = IncreaseAvailableCreatures.new(@dwelling_id, @creature_id, 3)
        execute_command(recruit_creature)

        # then
        expected_event = AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 4)
        then_domain_event(@stream_name, expected_event)
      end
    end
  end
end
