require "real_event_store_integration_test_case"
require "heroes/astrologers/write/proclaim_week_symbol/command_proclaim_week_symbol"
require "heroes/astrologers/write/proclaim_week_symbol/rule_one_symbol_per_week"
require "building_blocks/application/app_context"

module Heroes
  module Astrologers
    class ProclaimWeekSymbolApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @game_id = SecureRandom.uuid
        @stream_name ="Game::$#{@game_id}::Astrologers::WeekSymbols"
        @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
      end

      def test_given_nothing_when_proclaim_week_symbol_then_success
        # when
        month = 4
        week = 2
        week_of = "angel"
        growth = +5
        proclaim_week_symbol = ProclaimWeekSymbol.new(month, week, week_of, growth)
        execute_command(proclaim_week_symbol, @app_context)

        # then
        expected_event = WeekSymbolProclaimed.new(month, week, week_of, growth)
        then_domain_event(@stream_name, expected_event)
      end

      def test_given_week_symbol_proclaimed_when_proclaim_week_symbol_for_the_same_week_then_failed
        # given
        month = 1
        week = 1
        week_of = "black_dragon"
        growth = +2
        given_domain_event(@stream_name, WeekSymbolProclaimed.new(month, week, week_of, growth))

        # when - then
        proclaim_week_symbol = ProclaimWeekSymbol.new(month, week, week_of, growth)
        assert_raises(OnlyOneSymbolPerWeek) do
          execute_command(proclaim_week_symbol, @app_context)
        end
      end

      def test_given_week_symbol_proclaimed_when_proclaim_week_symbol_for_the_past_week_then_failed
        # given
        month = 1
        week = 4
        week_of = "titan"
        growth = +3
        given_domain_event(@stream_name, WeekSymbolProclaimed.new(month, week, week_of, growth))

        # when - then
        proclaim_week_symbol = ProclaimWeekSymbol.new(month, week - 1, week_of, growth)
        assert_raises(OnlyOneSymbolPerWeek) do
          execute_command(proclaim_week_symbol, @app_context)
        end
      end

      def default_app_context
        @app_context
      end
    end
  end
end
