require "real_event_store_integration_test_case"
require "heroes/calendar/write/start_day/event_day_started"
require "heroes/astrologers/write/proclaim_week_symbol/command_proclaim_week_symbol"

module Heroes
  module Astrologers
    class WhenWeekStartedThenProclaimWeekSymbolAutomationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @game_id = SecureRandom.uuid
        @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
        @calendar_stream = "Game::$#{@game_id}::Calendar"
        @astrologers_available_symbols_provider = %w[angel]
        @astrologers_growth_provider = -> { 3 }
      end

      def test_when_first_day_of_week_started_then_proclaim_week_symbol
        # given
        given_domain_event(@calendar_stream, Heroes::Calendar::DayStarted.new(month: 1, week: 1, day: 1))

        # when
        # The automation should react to the DayStarted event

        # then
        expected_command = Heroes::Astrologers::ProclaimWeekSymbol.new(
          month: 1,
          week: 1,
          week_of: "angel",
          growth: 3
        )
        assert_includes(@recording_command_bus.recorded, expected_command)
      end

      def test_when_not_first_day_of_week_started_then_do_not_proclaim_week_symbol
        # given
        given_domain_event(@calendar_stream, Heroes::Calendar::DayStarted.new(month: 1, week: 1, day: 2))

        # when
        # The automation should not react to this DayStarted event

        # then
        assert_empty(@recording_command_bus.recorded)
      end

      def default_app_context
        @app_context
      end
    end
  end
end
