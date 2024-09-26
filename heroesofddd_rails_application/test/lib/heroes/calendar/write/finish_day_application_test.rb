require "real_event_store_integration_test_case"
require "heroes/calendar/write/start_day/command_start_day"
require "heroes/calendar/write/finish_day/rule_can_only_finish_the_current_day"
require "heroes/calendar/write/finish_day/command_finish_day"
require "building_blocks/application/app_context"

module Heroes
  module Calendar
    class FinishDayApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @game_id = SecureRandom.uuid
        @stream_name = "Game::$#{@game_id}::Calendar"
        @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
      end

      def test_given_day_started_when_finish_current_day_then_day_finished
        # given
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: 1))

        # when
        finish_day = FinishDay.new(month: 1, week: 1, day: 1)
        execute_command(finish_day)

        # then
        expected_event = DayFinished.new(month: 1, week: 1, day: 1)
        then_domain_event(@stream_name, expected_event)
      end

      def test_given_day_started_when_finish_non_current_day_then_fails
        # given
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: 1))

        # when/then
        finish_day = FinishDay.new(month: 1, week: 1, day: 2)
        assert_raises(CanOnlyFinishCurrentDay) do
          execute_command(finish_day)
        end
      end

      def default_app_context
        @app_context
      end
    end
  end
end
