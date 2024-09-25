module Heroes
  module Astrologers
    class WhenWeekSymbolProclaimedThenIncreaseDwellingAvailableCreaturesApplicationTest < RealEventStoreIntegrationTestCase

      def test_given_nothing_when_proclaim_week_symbol_then_success
        # when
        month = 4
        week = 2
        week_of = "angel"
        growth = +5
        proclaim_week_symbol = ProclaimWeekSymbol.new(month, week, week_of, growth)
        execute_command(proclaim_week_symbol)

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
          execute_command(proclaim_week_symbol)
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
          execute_command(proclaim_week_symbol)
        end
      end
    end
  end
end
