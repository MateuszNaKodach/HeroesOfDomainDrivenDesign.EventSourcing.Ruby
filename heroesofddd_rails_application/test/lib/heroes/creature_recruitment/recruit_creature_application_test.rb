require "in_memory_event_store_test_case"
require "real_event_store_integration_test_case"
require "heroes/creature_recruitment/write/recruit_creature/command_recruit_creature"
require "heroes/creature_recruitment/write/recruit_creature/rule_not_exceed_available_creatures"
require "heroes/shared_kernel/resources"

module Heroes
  module CreatureRecruitment
    class RecruitCreatureApplicationTest < InMemoryEventStoreTestCase
      def setup
        super
        @dwelling_id = SecureRandom.uuid
        @creature_id = "angel"
        @cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([:GOLD, 3000], [:GEM, 1])
        @stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"
      end

      def test_given_not_built_dwelling_when_recruit_creature_then_failed
        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 1)

        # then
        assert_raises(RecruitCreaturesNotExceedAvailableCreatures) do
          execute_command(recruit_creature)
        end
      end

      def test_given_built_but_empty_dwelling_when_recruit_creature_then_failed
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))

        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 1)

        # then
        assert_raises(RecruitCreaturesNotExceedAvailableCreatures) do
          execute_command(recruit_creature)
        end
      end

      def test_given_dwelling_with_1_creature_when_recruit_1_creature_then_success
        # given
        given_domain_event(@stream_name, DwellingBuilt.new(@dwelling_id, @creature_id, @cost_per_troop))
        given_domain_event(@stream_name, AvailableCreaturesChanged.new(@dwelling_id, @creature_id, 1))

        # when
        recruit_creature = RecruitCreature.new(@dwelling_id, @creature_id, 1)
        execute_command(recruit_creature)

        # then
        then_stored_event(@stream_name, EventStore::Heroes::CreatureRecruitment::CreatureRecruited, {
          dwelling_id: @dwelling_id,
          creature_id: @creature_id,
          recruited: 1
        })
      end

    end
  end
end