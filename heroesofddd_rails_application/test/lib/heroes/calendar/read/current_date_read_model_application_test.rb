require "real_event_store_integration_test_case"
require "minitest/autorun"
require "minitest/spec"

module Heroes
  module Calendar
    class CurrentDateReadModelApplicationTest < RealEventStoreIntegrationTestCase
      def setup
        super
        @game_id = SecureRandom.uuid
        @stream_name = "Game::$#{@game_id}::Calendar"
        @app_context = ::BuildingBlocks::Application::AppContext.for_game(@game_id)
      end

      def test_create_on_first_day_started
        # given
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: 1))

        # when
        state = CurrentDateReadModel::State.find_by(game_id: @game_id)

        # then
        assert_equal @game_id, state.game_id
        assert_equal 1, state.month
        assert_equal 1, state.week
        assert_equal 1, state.day
      end

      def test_update_on_next_day_started
        # given
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: 1))
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: 2))

        # when
        state = CurrentDateReadModel::State.find_by(game_id: @game_id)

        # then
        assert_equal @game_id, state.game_id
        assert_equal 1, state.month
        assert_equal 1, state.week
        assert_equal 2, state.day
      end

      def test_update_on_new_week_started
        # given
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 1, day: 7))
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 2, day: 1))

        # when
        state = CurrentDateReadModel::State.find_by(game_id: @game_id)

        # then
        assert_equal @game_id, state.game_id
        assert_equal 1, state.month
        assert_equal 2, state.week
        assert_equal 1, state.day
      end

      def test_update_on_new_month_started
        # given
        given_domain_event(@stream_name, DayStarted.new(month: 1, week: 4, day: 7))
        given_domain_event(@stream_name, DayStarted.new(month: 2, week: 1, day: 1))

        # when
        state = CurrentDateReadModel::State.find_by(game_id: @game_id)

        # then
        assert_equal @game_id, state.game_id
        assert_equal 2, state.month
        assert_equal 1, state.week
        assert_equal 1, state.day
      end

      def default_app_context
        @app_context
      end
    end
  end
end
