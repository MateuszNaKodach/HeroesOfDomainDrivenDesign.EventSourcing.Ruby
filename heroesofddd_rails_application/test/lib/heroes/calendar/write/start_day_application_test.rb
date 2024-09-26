require "real_event_store_integration_test_case"
require "heroes/calendar/write/start_day/command_start_day"
require "heroes/calendar/write/start_day/event_day_started"
require "heroes/calendar/write/finish_day/command_finish_day"
require "heroes/calendar/write/finish_day/event_day_finished"
require "building_blocks/application/app_context"

module Heroes
  module Calendar
    class StartDayApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @game_id = SecureRandom.uuid
        @stream_name = "Game::$#{@game_id}::Calendar"
        @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
      end

      def test_given_no_previous_day_when_start_day_then_day_started
        # when
        start_day = StartDay.new(month: 1, week: 1, day: 1)
        execute_command(start_day)

        # then
        expected_event = DayStarted.new(month: 1, week: 1, day: 1)
        then_domain_event(@stream_name, expected_event)
      end

      def test_given_previous_day_finished_when_start_next_day_then_next_day_started
        # given
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: 1))
        given_domain_event(@stream_name, DayFinished.new(month: 1, week: 1, day: 1))

        # when
        start_day = StartDay.new(month: 1, week: 1, day: 2)
        execute_command(start_day)

        # then
        expected_event = DayStarted.new(month: 1, week: 1, day: 2)
        then_domain_event(@stream_name, expected_event)
      end

      def test_given_previous_day_finished_when_start_day_skipping_one_then_fails
        # given
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: 1))
        given_domain_event(@stream_name, DayFinished.new(month: 1, week: 1, day: 1))

        # when/then
        start_day = StartDay.new(month: 1, week: 1, day: 3)
        assert_raises(RuntimeError, "Cannot skip days") do
          execute_command(start_day)
        end
      end

      def test_given_last_day_of_week_finished_when_start_first_day_of_next_week_then_new_week_started
        # given
        (1..7).each do |day|
          given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: day))
          given_domain_event(@stream_name, DayFinished.new(month: 1, week: 1, day: day))
        end

        # when
        start_day = StartDay.new(month: 1, week: 2, day: 1)
        execute_command(start_day)

        # then
        expected_event = DayStarted.new(month: 1, week: 2, day: 1)
        then_domain_event(@stream_name, expected_event)
      end

      def test_given_last_day_of_month_finished_when_start_first_day_of_next_month_then_new_month_started
        # given
        (1..4).each do |week|
          (1..7).each do |day|
            given_domain_event(@stream_name, DayStarted.new(month: 1, week: week, day: day))
            given_domain_event(@stream_name, DayFinished.new(month: 1, week: week, day: day))
          end
        end

        # when
        start_day = StartDay.new(month: 2, week: 1, day: 1)
        execute_command(start_day)

        # then
        expected_event = DayStarted.new(month: 2, week: 1, day: 1)
        then_domain_event(@stream_name, expected_event)
      end

      def default_app_context
        @app_context
      end
    end
  end
end
