require "real_event_store_integration_test_case"
require "heroes/astrologers/write/proclaim_week_symbol/command_proclaim_week_symbol"
require "heroes/creature_recruitment/write/build_dwelling/event_dwelling_built"
require "heroes/creature_recruitment/write/change_available_creatures/command_increase_available_creatures"

module Heroes
  module Astrologers
    class WhenWeekSymbolProclaimedThenIncreaseDwellingAvailableCreaturesApplicationTest < RealEventStoreIntegrationTestCase
      def test_case_1
        # given
        angel_dwelling_id_1 = given_dwelling_built_event("angel")
        angel_dwelling_id_2 = given_dwelling_built_event("angel")
        titan_dwelling_id = given_dwelling_built_event("titan")

        # when
        sleep(1)
        proclaim_week_symbol = ProclaimWeekSymbol.new(1, 1, "angel", +2)
        execute_command(proclaim_week_symbol)

        # then
        expected_command_1 = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(angel_dwelling_id_1, "angel", +2)
        then_command_executed(expected_command_1)

        expected_command_2 = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(angel_dwelling_id_2, "angel", +2)
        then_command_executed(expected_command_2)

        not_expected_command = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(titan_dwelling_id, "titan", +2)
        then_command_not_executed(not_expected_command)
      end

      private

      def given_dwelling_built_event(creature_id)
        dwelling_id = SecureRandom.uuid
        cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])
        stream_name = "CreatureRecruitment::Dwelling$#{@dwelling_id}"

        given_domain_event(stream_name, ::Heroes::CreatureRecruitment::DwellingBuilt.new(dwelling_id, creature_id, cost_per_troop))
        dwelling_id
      end

      def then_command_executed(command)
        assert_includes(@recording_command_bus.recorded, command)
      end

      def then_command_not_executed(command)
        assert_not_includes(@recording_command_bus.recorded, command)
      end
    end
  end
end
