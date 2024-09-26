require "real_event_store_integration_test_case"
require "heroes/astrologers/write/proclaim_week_symbol/command_proclaim_week_symbol"
require "heroes/creature_recruitment/write/build_dwelling/event_dwelling_built"
require "heroes/creature_recruitment/write/change_available_creatures/command_increase_available_creatures"

module Heroes
  module Astrologers
    class WhenWeekSymbolProclaimedThenIncreaseDwellingAvailableCreaturesApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @game_id = SecureRandom.uuid
        @metadata = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
      end

      def test_when_week_symbol_proclaimed_then_increase_symbol_creatures_dwellings_available_creatures
        # given
        angel_dwelling_id_1 = given_dwelling_built_event("angel")
        angel_dwelling_id_2 = given_dwelling_built_event("angel")
        titan_dwelling_id = given_dwelling_built_event("titan")

        # when
        proclaim_week_symbol = ProclaimWeekSymbol.new(1, 1, "angel", +2)
        execute_command(proclaim_week_symbol, @metadata)

        # then
        expected_command_1 = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(angel_dwelling_id_1, "angel", +2)
        then_command_executed(expected_command_1)

        expected_command_2 = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(angel_dwelling_id_2, "angel", +2)
        then_command_executed(expected_command_2)

        not_expected_command = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(titan_dwelling_id, "titan", +2)
        then_command_not_executed(not_expected_command)
      end

      def test_when_week_symbol_proclaimed_then_increase_all_dwellings_built_till_the_proclamation
        # given
        angel_dwelling_id_1 = given_dwelling_built_event("angel")
        given_week_symbol_proclaimed(1, 1, "angel", +2)
        angel_dwelling_id_2 = given_dwelling_built_event("angel")

        # when
        proclaim_week_symbol = ProclaimWeekSymbol.new(1, 2, "angel", +3)
        execute_command(proclaim_week_symbol, @metadata)

        # then
        expected_command_1 = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(angel_dwelling_id_1, "angel", +3)
        then_command_executed(expected_command_1)

        expected_command_2 = ::Heroes::CreatureRecruitment::IncreaseAvailableCreatures.new(angel_dwelling_id_2, "angel", +3)
        then_command_executed(expected_command_2)
      end

      private

      def given_dwelling_built_event(creature_id)
        dwelling_id = SecureRandom.uuid
        cost_per_troop = Heroes::SharedKernel::Resources::Cost.resources([ :GOLD, 3000 ], [ :GEM, 1 ])
        stream_name = "Game::$#{@game_id}::CreatureRecruitment::Dwelling$#{dwelling_id}"

        given_domain_event(stream_name, ::Heroes::CreatureRecruitment::DwellingBuilt.new(dwelling_id, creature_id, cost_per_troop))
        dwelling_id
      end

      def given_week_symbol_proclaimed(month, week, symbol, growth)
        dwelling_id = SecureRandom.uuid
        stream_name = "Game::$#{@game_id}::Astrologers::WeekSymbols"

        given_domain_event(stream_name, ::Heroes::Astrologers::WeekSymbolProclaimed.new(month, week, symbol, growth))
        dwelling_id
      end

      def then_command_executed(command)
        assert_includes(@recording_command_bus.recorded, command)
      end

      def then_command_not_executed(command)
        assert_not_includes(@recording_command_bus.recorded, command)
      end

      def game_metadata
        @metadata
      end
    end
  end
end
