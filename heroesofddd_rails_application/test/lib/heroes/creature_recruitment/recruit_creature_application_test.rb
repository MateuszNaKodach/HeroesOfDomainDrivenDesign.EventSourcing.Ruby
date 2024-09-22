require "in_memory_event_store_test_case"
require "real_event_store_integration_test_case"
require "heroes/creature_recruitment/write/recruit_creature/command_recruit_creature"
require "heroes/creature_recruitment/write/recruit_creature/rule_not_exceed_available_creatures"

module Heroes
  module CreatureRecruitment
    class RecruitCreatureApplicationTest < InMemoryEventStoreTestCase
      stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"

      def test_given_not_built_dwelling_when_recruit_creature_then_failed
        # given
        # given_domain_event(stream_name, )

        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 1)

        # then
        assert_raises(RecruitCreaturesNotExceedAvailableCreatures) do
          execute_command(recruit_creature)
        end
      end
    end
  end
end