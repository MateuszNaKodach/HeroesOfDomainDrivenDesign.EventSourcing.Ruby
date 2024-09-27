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
        given_domain_event(@stream_name, DayStarted.new(year: 1, month: 1, day: 1))

        # when
        state = CurrentDateReadModel::State.find_by(game_id: @game_id)

        # then
        expected_state = CurrentDateReadModel::State.new(
          game_id: @game_id,
          year: 1,
          month: 1,
          day: 1
        )
        assert_equal expected_state.attributes, state.attributes
      end

      def test_update_on_next_day_started
        # given
        given_domain_event(@stream_name, DayStarted.new(year: 1, month: 1, day: 1))
        given_domain_event(@stream_name, DayStarted.new(year: 1, month: 1, day: 2))

        # when
        state = CurrentDateReadModel::State.find_by(game_id: @game_id)

        # then
        expected_state = CurrentDateReadModel::State.new(
          game_id: @game_id,
          year: 1,
          month: 1,
          day: 2
        )
        assert_equal expected_state.attributes, state.attributes
      end

      def test_update_on_new_month_started
        # given
        given_domain_event(@stream_name, DayStarted.new(year: 1, month: 1, day: 30))
        given_domain_event(@stream_name, DayStarted.new(year: 1, month: 2, day: 1))

        # when
        state = CurrentDateReadModel::State.find_by(game_id: @game_id)

        # then
        expected_state = CurrentDateReadModel::State.new(
          game_id: @game_id,
          year: 1,
          month: 2,
          day: 1
        )
        assert_equal expected_state.attributes, state.attributes
      end

      def test_update_on_new_year_started
        # given
        given_domain_event(@stream_name, DayStarted.new(year: 1, month: 12, day: 31))
        given_domain_event(@stream_name, DayStarted.new(year: 2, month: 1, day: 1))

        # when
        state = CurrentDateReadModel::State.find_by(game_id: @game_id)

        # then
        expected_state = CurrentDateReadModel::State.new(
          game_id: @game_id,
          year: 2,
          month: 1,
          day: 1
        )
        assert_equal expected_state.attributes, state.attributes
      end

      def default_app_context
        @app_context
      end
    end
  end
end